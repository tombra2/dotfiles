return {
  {
    "Jezda1337/nvim-html-css",
    ft = { "html", "twig" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable_on = { "html", "twig" },
      style_sheets = {
        "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
      },
    },
  },
}
