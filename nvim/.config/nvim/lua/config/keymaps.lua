vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- Paste over selection without yanking the replaced text into the register
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<C-f>", function()
  vim.cmd('silent !"$HOME/.config/script/herdr-sessionizer"')
  vim.cmd("redraw!")
end, { desc = "Herdr sessionizer" })

vim.keymap.set({ "n", "t" }, "<C-7>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

vim.keymap.set("n", "U", ":UndotreeToggle | wincmd h<CR>")
vim.keymap.set("n", "<leader>a", "ggVG")
vim.keymap.set({ "n", "x", "o" }, "<CR>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end)

vim.keymap.set({ "n", "x", "o" }, "<BS>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end)

-- JetBrains-style intention actions
vim.keymap.set({ "n", "x" }, "<M-CR>", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("i", "<M-CR>", function()
  vim.cmd("stopinsert")
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })

-- Analyse the current file with PHPStan in a terminal
vim.keymap.set("n", "<leader>cqp", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  vim.cmd.write({ mods = { silent = true } })
  local phpstan = vim.fs.root(file, "vendor") and (vim.fs.root(file, "vendor") .. "/vendor/bin/phpstan") or "phpstan"
  Snacks.terminal.open({ phpstan, "analyse", file }, { interactive = false, win = { position = "bottom" } })
end, { desc = "PHPStan analyse current file" })
