return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {

			-- Lua
			lua = { "stylua" },

			-- Web technologies
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },

			-- Python
			python = { "isort", "black" },

			-- PHP/Symfony
			php = { "php-cs-fixer" },

			-- Shell
			sh = { "shfmt" },
			bash = { "shfmt" },

			-- Java --
			java = { "google-java-format" },

			-- Additional file types (uncomment as needed)
			-- markdown = { "markdownlint" },
			-- yaml = { "yamllint" },
			-- toml = { "taplo" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = {
			timeout_ms = 1000,
		},
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
