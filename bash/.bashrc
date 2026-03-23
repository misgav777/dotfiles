# ─── Environment ──────────────────────────────────────────────────────────────
export LC_TIME=en_US.UTF-8
export EDITOR='nvim'

# ─── NVM (lazy load) ──────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
# Pre-add default node to PATH so global tools work without triggering nvm
[[ -f "$NVM_DIR/alias/default" ]] && {
  _nvm_ver=$(<"$NVM_DIR/alias/default")
  [[ "$_nvm_ver" == lts/* ]] && [[ -f "$NVM_DIR/alias/$_nvm_ver" ]] && _nvm_ver=$(<"$NVM_DIR/alias/$_nvm_ver")
  [[ -d "$NVM_DIR/versions/node/$_nvm_ver/bin" ]] && export PATH="$NVM_DIR/versions/node/$_nvm_ver/bin:$PATH"
  unset _nvm_ver
}
nvm() {
  unset -f nvm node npm npx
  local _sh="/opt/homebrew/opt/nvm/nvm.sh"
  [[ -s "$_sh" ]] || _sh="$NVM_DIR/nvm.sh"
  local _comp="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  [[ -s "$_comp" ]] || _comp="$NVM_DIR/bash_completion"
  [[ -s "$_sh" ]]   && . "$_sh"
  [[ -s "$_comp" ]] && . "$_comp"
  nvm "$@"
}
node() { nvm use default --silent; node "$@"; }
npm()  { nvm use default --silent; npm  "$@"; }
npx()  { nvm use default --silent; npx  "$@"; }

# ─── SDKman ───────────────────────────────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ─── Terraform ────────────────────────────────────────────────────────────────
alias tf='terraform'
if _tf=$(command -v terraform 2>/dev/null); then
  complete -o nospace -C "$_tf" terraform
  unset _tf
fi

# ─── Integrations ─────────────────────────────────────────────────────────────
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ─── Prompt ───────────────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init bash)"

# ─── fzf ──────────────────────────────────────────────────────────────────────
command -v fzf &>/dev/null && eval "$(fzf --bash)"
