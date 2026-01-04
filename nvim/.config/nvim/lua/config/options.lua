vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.scrolloff = 8
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.cursorline = false
vim.opt.path:append("templates")
vim.opt.suffixesadd:append(".twig")
vim.g.have_nerd_font = true
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.filetype.add({
	extension = {
		twig = "twig",
	},
})
vim.g.lazyvim_check_order = false
vim.o.signcolumn = "yes"
vim.opt.path:append("templates")
vim.opt.suffixesadd:append(".twig")
