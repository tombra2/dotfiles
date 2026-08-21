# Dotfiles

## Repository Workflow

- This is a GNU Stow repository. Each top-level tool directory is an independent package whose paths mirror the target under `$HOME` (for example, `waybar/.config/waybar` -> `~/.config/waybar`). Run Stow from the repository root and target only the package being changed: `stow <package>...`.
- There is no root build, test, lint, or package-manager workflow. Validate changes with the component-specific commands below; do not invent a project-wide test command.
- Read the package-local instructions before editing Neovim or Kanata: `nvim/.config/nvim/CLAUDE.md` and `kanata/.config/kanata/CLAUDE.md`.

## Runtime Validation

- Hyprland configuration is Lua and is loaded by `hypr/.config/hypr/hyprland.lua` together with Omarchy defaults. After editing it, run `hyprctl reload` followed by `hyprctl configerrors`.
- Kanata uses the user systemd service, not the disabled system service. From `kanata/.config/kanata/`, run `kanata --check --cfg kanata.kbd`, then apply changes with `systemctl --user restart kanata`.

## Omarchy Themes

- Treat `omarchy/.config/omarchy/current/` as active theme state managed by Omarchy. Edit a named theme under `omarchy/.config/omarchy/themes/` and activate it through Omarchy rather than editing `current/` directly.
- Never modify Omarchy's upstream files under `~/.local/share/omarchy/`; user customizations belong in this repository's stowed configuration.
