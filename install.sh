#!/usr/bin/env bash
# Bootstrap dotfiles on macOS or Amazon Linux.
# Usage: bash install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# ─── Helpers ──────────────────────────────────────────────────────────────────
log()  { printf '\033[0;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[0;32m    ✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[0;33m    ! %s\033[0m\n' "$*"; }

symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "already linked: $dst"
  elif [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "skipping $dst — file exists (remove manually to re-link)"
  else
    [[ -L "$dst" ]] && rm "$dst"   # stale symlink
    ln -s "$src" "$dst"
    ok "linked: $dst"
  fi
}

# ─── OS Detection ─────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi "amazon linux" /etc/os-release 2>/dev/null; then
        echo "amazon"
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)
log "Detected OS: $OS"

# ─── macOS ────────────────────────────────────────────────────────────────────
install_macos() {
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  log "Installing packages via Homebrew..."
  brew install neovim tmux fzf fd starship \
    zsh-autosuggestions zsh-syntax-highlighting
}

# ─── Amazon Linux ─────────────────────────────────────────────────────────────
install_amazon() {
  log "Installing base packages..."
  if command -v dnf &>/dev/null; then
    sudo dnf install -y git curl zsh tmux fzf unzip tar
  else
    sudo yum install -y git curl zsh tmux unzip tar
    # fzf not in yum on AL2 — install from git
    if ! command -v fzf &>/dev/null; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      ~/.fzf/install --bin
      sudo cp ~/.fzf/bin/fzf /usr/local/bin/fzf
    fi
  fi

  # neovim — not in standard repos, install from GitHub release
  if ! command -v nvim &>/dev/null; then
    log "Installing neovim..."
    local arch; arch=$(uname -m)
    local tarball
    case "$arch" in
      x86_64)  tarball="nvim-linux-x86_64.tar.gz" ;;
      aarch64) tarball="nvim-linux-arm64.tar.gz" ;;
      *)       warn "Unknown arch $arch — skipping neovim"; tarball="" ;;
    esac
    if [[ -n "$tarball" ]]; then
      curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${tarball}" \
        | sudo tar -xz -C /usr/local --strip-components=1
    fi
  fi

  # fd — needed by telescope's find_files
  if ! command -v fd &>/dev/null; then
    log "Installing fd..."
    local arch; arch=$(uname -m)
    local ver; ver=$(curl -fsSL "https://api.github.com/repos/sharkdp/fd/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    local tarball
    case "$arch" in
      x86_64)  tarball="fd-v${ver}-x86_64-unknown-linux-gnu.tar.gz" ;;
      aarch64) tarball="fd-v${ver}-aarch64-unknown-linux-gnu.tar.gz" ;;
    esac
    local tmpdir; tmpdir=$(mktemp -d)
    curl -fsSL "https://github.com/sharkdp/fd/releases/download/v${ver}/${tarball}" \
      | tar -xz -C "$tmpdir" --strip-components=1
    sudo mv "$tmpdir/fd" /usr/local/bin/fd
    rm -rf "$tmpdir"
  fi

  # starship
  if ! command -v starship &>/dev/null; then
    log "Installing starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  fi

  # zsh plugins — clone into dotfiles so .zshrc can source them
  local plugins_dir="$DOTFILES/zsh/plugins"
  if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
    log "Cloning zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
      "$plugins_dir/zsh-autosuggestions"
  fi
  if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
    log "Cloning zsh-syntax-highlighting..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$plugins_dir/zsh-syntax-highlighting"
  fi

  # Add zsh to /etc/shells and set as default
  local zsh_bin; zsh_bin=$(command -v zsh)
  if ! grep -qxF "$zsh_bin" /etc/shells; then
    echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
  fi
}

# ─── Run platform install ─────────────────────────────────────────────────────
case "$OS" in
  macos)  install_macos ;;
  amazon) install_amazon ;;
  *)      warn "Unsupported OS — skipping package installation" ;;
esac

# ─── Git submodules ───────────────────────────────────────────────────────────
log "Initialising git submodules..."
cd "$DOTFILES"
git submodule update --init --recursive

# ─── Symlinks ─────────────────────────────────────────────────────────────────
log "Creating symlinks..."
symlink "$DOTFILES/zsh/.zshrc"                          "$HOME/.zshrc"
symlink "$DOTFILES/starship/starship.toml"              "$XDG_CONFIG/starship.toml"
symlink "$DOTFILES/tmux/tmux.conf"                      "$XDG_CONFIG/tmux/tmux.conf"
symlink "$DOTFILES/nvim"                                "$XDG_CONFIG/nvim"
symlink "$DOTFILES/markdownlint/.markdownlint.yaml"     "$HOME/.markdownlint.yaml"

# ─── Default shell ────────────────────────────────────────────────────────────
if [[ "$SHELL" != */zsh ]] && command -v zsh &>/dev/null; then
  log "Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
fi

log "Done! Open a new shell or run: exec zsh"
