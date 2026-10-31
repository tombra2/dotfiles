require("config.remote_clipboard").setup()

vim.opt.clipboard = "unnamedplus"
-- Show Copilot suggestions as inline ghost text instead of as entries in the
-- blink completion menu (LazyVim ai.copilot extra keys off this flag).
vim.g.ai_cmp = false
vim.g.lazyvim_php_lsp = "intelephense"

vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"

local function set_cursorline_color()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1f2024" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("CustomCursorLine", { clear = true }),
  callback = set_cursorline_color,
})
set_cursorline_color()
vim.opt.spell = true
vim.opt.spelllang = "de,en"
