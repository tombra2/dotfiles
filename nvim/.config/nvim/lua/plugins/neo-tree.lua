return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      commands = {
        open_and_close = function(state)
          local node = state.tree:get_node()
          state.commands["open"](state)
          if node.type ~= "directory" then
            vim.cmd("Neotree close")
          end
        end,
      },
      window = {
        mappings = {
          ["<cr>"] = "open_and_close",
        },
      },
    },
  },
}
