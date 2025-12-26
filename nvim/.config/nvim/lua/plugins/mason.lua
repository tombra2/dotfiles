return {

	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
		keys = {
			{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",

			opts = {
				ensure_installed = {
					"lua_ls",
					"pyright",
					"intelephense",
					"clangd",
					"html",
					"emmet_ls",
					"twiggy_language_server",
					"vtsls",
					"vimls",
					"bashls",
					"cssls",
					"jdtls",
					--------LINTER-------
					"cppcheck",
					"cpplint",
				},
			},
		},
	},
}
