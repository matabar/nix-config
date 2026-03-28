# nix-config

Fully reproducible Mac setup using [nix-darwin](https://github.com/LnL7/nix-darwin).

## Fresh Mac Setup

1. Install [Determinate Nix](https://determinate.systems/nix-installer/)
2. Install [Homebrew](https://brew.sh)
3. Clone and apply:

```sh
git clone https://github.com/matabar/nix-config ~/Projects/matabar/nix-config
ln -s ~/Projects/matabar/nix-config ~/.config/nix-darwin
darwin-rebuild switch --flake ~/Projects/matabar/nix-config
```

## What's Included

### Nix Packages
vim, git, jq, neovim, tmux, htop, claude-code, gh, zoxide, starship

### Homebrew Casks
cmux, docker-desktop, gitkraken, slack, discord, spotify, rectangle, wispr-flow

### Shell
- **zsh** with starship prompt and zoxide (smart `cd`)
- JetBrainsMono Nerd Font

### macOS Defaults
- Dark mode
- Dock auto-hide, no MRU spaces
- Finder shows all extensions
- Fast key repeat
- Touch ID for sudo
- Dia as default browser

## Applying Changes

```sh
darwin-rebuild switch --flake ~/Projects/matabar/nix-config
```
