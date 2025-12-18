return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter")

		configs.setup({
			ensure_installed = {
				"arduino",
				"cpp",
				"python",
				"cpp",
				"c",
				"twig",
				"lua",
				"vim",
				"vimdoc",
				"css",
				"scss",
				"query",
				"javascript",
				"php",
				"html",
				"markdown",
				"markdown_inline",
			},
			auto_install = true,
			sync_install = true,
			highlight = { enable = true },
			indent = { enable = true },

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "enter", -- set to `false` to disable one of the mappings
					node_incremental = "enter",
					scope_incremental = false,
					node_decremental = "backspace",
				},
			},
		})
	end,
}
