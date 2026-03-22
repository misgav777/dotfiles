# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git vscode zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ─── Environment ──────────────────────────────────────────────────────────────
export LC_TIME=en_US.UTF-8
export EDITOR='nvim'

# ─── Path ─────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export PATH="/usr/local/share/dotnet:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@11"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@11/include"

# ─── NVM (lazy load) ──────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
# Eagerly add default node bin to PATH so global npm tools (e.g. claude) work without triggering nvm
[[ -f "$NVM_DIR/alias/default" ]] && export PATH="$NVM_DIR/versions/node/$(cat $NVM_DIR/alias/default)/bin:$PATH"
nvm() {
  unset -f nvm node npm npx
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}
node() { nvm use default --silent; node "$@"; }
npm()  { nvm use default --silent; npm  "$@"; }
npx()  { nvm use default --silent; npx  "$@"; }

# ─── SDKman ───────────────────────────────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ─── Terraform ────────────────────────────────────────────────────────────────
alias tf='terraform'
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# ─── Keybindings ──────────────────────────────────────────────────────────────
bindkey -v

# ─── Integrations ─────────────────────────────────────────────────────────────
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
. "$HOME/.local/bin/env"

# ─── Prompt ───────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
