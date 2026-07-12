return {
  "ibhagwan/fzf-lua",
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
