# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Neovim version: 0.12.2**

This is a [LazyVim](https://lazyvim.github.io) Neovim configuration. LazyVim provides sensible defaults and a plugin ecosystem; this repo customizes it via files in `lua/config/` and `lua/plugins/`.

### Neovim 0.12 relevance

Since 0.10+ Neovim ships a built-in LSP client with a new configuration API (`vim.lsp.config` / `vim.lsp.enable`). As of 0.12, the old pattern of configuring servers through `nvim-lspconfig` directly is superseded — servers can be declared natively without the plugin. LazyVim abstracts this, but when writing custom LSP config prefer the native API over `require("lspconfig").serverName.setup({})`. The `vim.lsp.config("*", {...})` wildcard sets defaults for all servers.

## Formatting

Lua files are formatted with StyLua:
```
stylua .
```
Config: 2-space indentation, 120 column width (see `stylua.toml`).

## Architecture

**Entry point:** `init.lua` → `lua/config/lazy.lua` bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and loads two plugin specs:
1. `LazyVim/LazyVim` — the upstream LazyVim defaults
2. `{ import = "plugins" }` — all files under `lua/plugins/` (this repo's customizations)

**Config layer** (`lua/config/`):
- `options.lua` — vim options (currently disables relative line numbers)
- `keymaps.lua` — custom keymaps (visual-mode line moving with J/K, centered scroll, `U` for Undotree)
- `autocmds.lua` — custom autocommands (currently empty)

**Plugin customizations** (`lua/plugins/`): each file returns a lazy.nvim spec that adds, overrides, or disables a LazyVim plugin. Notable files:
- `blink.lua` — completion engine config (blink.cmp with LuaSnip, `enter` preset keymap, rounded borders)
- `dap-php.lua` — PHP debugger via nvim-dap with Xdebug on port 9003 (includes Docker path mapping)
- `neotest.lua` — PHP test runner via neotest-phpunit using `./vendor/bin/phpunit`
- `all-themes.lua` — loads all colorscheme plugins lazily so they're available for hot-reload
- `omarchy-theme-hotreload.lua` — listens for `LazyReload` events to hot-swap the active colorscheme; reads the active theme from `plugins/theme.lua` (not committed; managed by Omarchy)
- `disable.lua` — disables bufferline.nvim
- `transparency.lua` (in `plugin/after/`) — strips background from highlight groups to enable terminal transparency; re-sourced on colorscheme change

**LazyVim extras** (enabled via `lazyvim.json`):
- `dap.core` — DAP debugging support
- `editor.neo-tree` — file explorer
- `lang.tailwind` — Tailwind CSS LSP
- `lang.twig` — Twig template support
- `test.core` — neotest integration

## Theme system

The active colorscheme is set in `lua/plugins/theme.lua` (gitignored, managed by [Omarchy](https://omarchy.com)). To change the theme, use Omarchy's theme switcher rather than editing this file directly. The hot-reload system in `omarchy-theme-hotreload.lua` will apply changes without restarting Neovim.

## LSP debugging (Neovim 0.12)

In 0.12 the native `:lsp` command exists, so nvim-lspconfig skips registering `:LspInfo` / `:LspLog`. Use the native API instead:

- LSP status: `:checkhealth vim.lsp`
- LSP log: `:lua vim.cmd.edit(vim.lsp.log.get_filename())` (file: `~/.local/state/nvim/lsp.log`)
- Active clients for current buffer: `:lua vim.print(vim.lsp.get_clients({bufnr=0}))`

## Plugin naming

Mason was renamed: use `mason-org/mason.nvim` (not the old `williamboman/mason.nvim`). LazyVim itself already uses the new name; custom plugin specs must match.

## PHP development

The config is oriented toward PHP projects:
- LSP: Intelephense (`lua/plugins/php-lsp.lua`), licence key at `~/.config/intelephense/licence.txt`
- DAP adapter: `php-debug-adapter` (installed via Mason), listens on port 9003
- Tests: neotest-phpunit using the project-local `vendor/bin/phpunit`
- Run tests from within Neovim using neotest keymaps (LazyVim defaults: `<leader>t`)
