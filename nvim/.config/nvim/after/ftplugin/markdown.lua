-- Schreib-Komfort für Markdown / Obsidian-Notizen.
-- Liegt in after/ftplugin, läuft also nach LazyVims Markdown-Defaults.

vim.opt_local.wrap = true
vim.opt_local.linebreak = true -- Umbruch an Wortgrenzen statt mitten im Wort
vim.opt_local.breakindent = true -- eingerückte Fortsetzung bei Aufzählungen

vim.opt_local.spell = true
vim.opt_local.spelllang = "de,en"

vim.opt_local.conceallevel = 2 -- für render-markdown.nvim / obsidian.nvim

-- Bei weichem Umbruch pro Bildschirmzeile navigieren (nicht pro logischer Zeile)
vim.keymap.set({ "n", "x" }, "j", "gj", { buffer = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "gk", { buffer = true, silent = true })
