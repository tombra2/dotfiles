return {
  "ibhagwan/fzf-lua",
  opts = {
    files = {
      -- show the filename first, the directory dimmed behind it
      formatter = "path.filename_first",
    },
  },
  keys = {
    {
      "<leader><leader>",
      function()
        require("fzf-lua").buffers({ sort_lastused = true, no_current = true })
      end,
      desc = "Find Buffer",
    },
  },
}
