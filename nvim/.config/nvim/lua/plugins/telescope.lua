return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.0",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
		vim.keymap.set("n", "gd", builtin.lsp_definitions)
		vim.keymap.set("n", "gD", builtin.lsp_type_definitions)
		vim.keymap.set("n", "gi", builtin.lsp_implementations)
		vim.keymap.set("n", "gr", builtin.lsp_references)
		vim.keymap.set("n", "gci", builtin.lsp_incoming_calls)
		vim.keymap.set("n", "gco", builtin.lsp_outgoing_calls)
		vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)
		vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols)
		vim.keymap.set("n", "<leader>wS", builtin.lsp_dynamic_workspace_symbols)
		vim.keymap.set("n", "<leader>dd", builtin.diagnostics)
		vim.keymap.set("n", "<leader>db", function()
			builtin.diagnostics({ bufnr = 0 })
		end)
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<leader>sw", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>sW", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>ss", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
	end,
}
