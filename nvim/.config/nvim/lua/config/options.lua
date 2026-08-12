require("config.remote_clipboard").setup()
-- Show Copilot suggestions as inline ghost text instead of as entries in the
-- blink completion menu (LazyVim ai.copilot extra keys off this flag).
vim.g.ai_cmp = false
vim.g.lazyvim_php_lsp = "intelephense"

vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.cursorline = false
vim.opt.spell = true
vim.opt.spelllang = "de,en"
