return {
	-- Autotags
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},
	-- comments
	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
	},
	-- useful when there are embedded languages in certain types of files (e.g. Vue or React)
	{ "joosepalviste/nvim-ts-context-commentstring", lazy = true },

	-- Neovim plugin to improve the default vim.ui interfaces
	-- {
	--   "stevearc/dressing.nvim",
	--   dependencies = { "MunifTanjim/nui.nvim" },
	--   opts = {},
	--   config = function()
	--     require("dressing").setup()
	--   end,
	-- },

	-- Neovim notifications and LSP progress messages
	{
		"j-hui/fidget.nvim",
	},

	-- find and replace
	-- Heuristically set buffer options
	{
		"tpope/vim-sleuth",
	},

	-- editor config support
	{
		"editorconfig/editorconfig-vim",
	},

	-- persist sessions
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		opts = {},
	},

	{
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [']quote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			require("mini.pairs").setup()

			local statusline = require("mini.statusline")
			statusline.setup({
				use_icons = vim.g.have_nerd_font,
				set_vim_settings = false,
			})
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- Set all statusline sections to use one color
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { link = "StatusLine" })
			-- vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { link = "StatusLine" })
		end,
	},

	{
		"echasnovski/mini.icons",
		enabled = true,
		opts = {},
		lazy = true,
	},

	{
		"sphamba/smear-cursor.nvim",

		opts = {
			stiffness = 0.8, -- 0.6      [0, 1]
			trailing_stiffness = 0.6, -- 0.45     [0, 1]
			stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
			trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
			damping = 0.95, -- 0.85     [0, 1]
			damping_insert_mode = 0.95, -- 0.9      [0, 1]
			distance_stop_animating = 0.5, -- 0.1      > 0	-- Smear cursor when switching buffers or windows.

			smear_between_buffers = true,

			-- Smear cursor when moving within line or to neighbor lines.
			-- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
			smear_between_neighbor_lines = true,

			-- Draw the smear in buffer space instead of screen space when scrolling
			scroll_buffer_space = true,

			-- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
			-- Smears and particles will look a lot less blocky.
			legacy_computing_symbols_support = false,

			-- Smear cursor in insert mode.
			-- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
			smear_insert_mode = true,
		},
	},

	{
		"esmuellert/vscode-diff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("vscode-diff").setup({
				highlights = {
					-- Yukinord-compatible diff colors
					-- Line backgrounds: subtle, blended with yukinord's bg
					line_insert = "#2a3325", -- green-tinted bg based on yukinord green #a3be8c
					line_delete = "#362c2e", -- red-tinted bg based on yukinord red #bf616a
					-- Character highlights: more saturated versions
					char_insert = "#3d4f35", -- deeper green for inserted chars
					char_delete = "#4d3538", -- deeper red for deleted chars
				},

				keymaps = {
					view = {
						next_hunk = "]c", -- Jump to next change
						prev_hunk = "[c", -- Jump to previous change
						next_file = "]f", -- Next file in explorer mode
						prev_file = "[f", -- Previous file in explorer mode
					},
					explorer = {
						select = "<CR>", -- Open diff for selected file
						hover = "K", -- Show file diff preview
						refresh = "R", -- Refresh git status
					},
				},
			})
		end,
	},
}
