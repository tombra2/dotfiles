# Dotfiles

## Structure

This repo uses a per-tool directory structure. Most directories contain a dotfile or a `.config/<tool>/` subdirectory that maps directly to the target location.

Key directories:
- `zsh/.zshrc` → symlinked to `~/.zshrc`
- `git/.gitconfig` → symlinked to `~/.gitconfig`
- `tmux/.tmux.conf` → symlinked to `~/.tmux.conf`
- `nvim/.config/nvim/` → symlinked to `~/.config/nvim`
- `hypr/.config/hypr/` → symlinked to `~/.config/hypr`
- `kitty/.config/kitty/` → symlinked to `~/.config/kitty`
- `alacritty/.config/alacritty/` → symlinked to `~/.config/alacritty`
- `sesh/.config/sesh/` → symlinked to `~/.config/sesh`
- `script/.config/script/` → symlinked to `~/.config/script`
- `opencode/.config/opencode/` → symlinked to `~/.config/opencode`

## Installation

Uses `stow` for symlink management. Run from repo root:
```bash
stow zsh git tmux nvim hypr kitty alacritty sesh script opencode
```

## Key Aliases

From `.zshrc`:
- `n` → `nvim` (with optional path arg)
- `y` → `yazi` (file manager)
- `gs` → `git status --short`
- `lt` → `eza --tree --level=2 --long --icons --git`

## Tool-Specific Notes

### tmux
- Prefix: `Ctrl+Space`
- Uses tmux-sessionx, tmux-resurrect, tmux-continuum, and tokyo-night theme
- `K` opens sesh session picker

### nvim
- LazyVim starter template
- stylua.toml for Lua formatting config

### sesh
- Session definitions in `sesh/.config/sesh/sesh.toml`
- Pre-configured sessions for: git, zshrc, tmux, nvim, hypr, kitty, and various project directories

### hypr
- Hyprland (Wayland compositor) configuration
- Includes: hyprland.conf, hypridle.conf, hyprlock.conf, hyprsunset.conf, bindings, workspaces

## Git Config

Username: tom_brandi
Email: brandner.thomas@me.com
Uses GitHub CLI (`gh auth git-credential`) for credentials.

## Platform

Arch Linux with yay for AUR packages.
