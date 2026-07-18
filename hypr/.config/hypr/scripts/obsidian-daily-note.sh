#!/bin/bash
# Opens today's Obsidian daily note in Neovim, creating it (with the vault's
# usual frontmatter) if it doesn't exist yet. Bound to SUPER + N.
set -euo pipefail

vault_daily_dir="$HOME/nextcloud/Documents/daily"
today="$(date +%Y-%m-%d)"
note="$vault_daily_dir/$today.md"

mkdir -p "$vault_daily_dir"

if [ ! -f "$note" ]; then
	printf -- '---\nid: %s\naliases: []\ntags: []\n---\n\n## Daily Tasks\n- [ ] Sport\n- [ ] Tippen\n- [ ] boot.dev\n- [ ] Lesen\n\n' "$today" >"$note"
fi

exec nvim "$note"
