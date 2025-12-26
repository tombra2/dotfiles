vim.lsp.enable({
	"html",
	"lua_ls",
	"pyright",
	"emmet_ls",
	"bashls",
	"cssls",
	"intelephense",
	"jtdls",
	"vimls",
	"vtsls",
	"twiggy_language_server",
	"phpactor",
	"vimfony",
})
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
})
