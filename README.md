# dotfiles

My personal terminal configuration — works on macOS and Amazon Linux.

## Tools

| Tool | Config |
|------|--------|
| [zsh](https://www.zsh.org/) | `zsh/.zshrc` |
| [Neovim](https://neovim.io/) (LazyVim) | `nvim/` |
| [Starship](https://starship.rs/) | `starship/starship.toml` |
| [tmux](https://github.com/tmux/tmux) | `tmux/tmux.conf` |

## Install

```bash
git clone https://github.com/misgav777/dotfiles.git ~/dotfiles
bash ~/dotfiles/install.sh
```

The script will:
- Install required packages (Homebrew on macOS, dnf/yum on Amazon Linux)
- Symlink configs to their expected locations
- Set zsh as the default shell

## Symlinks

| Config | Target |
|--------|--------|
| `zsh/.zshrc` | `~/.zshrc` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `nvim/` | `~/.config/nvim/` |
| `markdownlint/.markdownlint.yaml` | `~/.markdownlint.yaml` |

## Neovim extras

Language support is managed via `nvim/lazyvim.json` (LazyVim extras UI: `:LazyExtras`):

- Copilot, Go, Python, Terraform, Helm, Docker, .NET, Angular, YAML, JSON, Markdown, Git
