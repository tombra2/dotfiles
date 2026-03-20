return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    spec = {
      {
        mode = { "n", "x" },
        { "<leader>a", group = "ardunio", icon = { icon = "", color = "#ff7f00" } },
      },
    },
  },
}
