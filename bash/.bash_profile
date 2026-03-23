# SSH login shells source .bash_profile, not .bashrc — forward to it
[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
