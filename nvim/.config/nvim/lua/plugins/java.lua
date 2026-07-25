return {
  {
    "nvim-java/nvim-java",
    config = function()
      require("java").setup({
        jdtls = {
          version = "1.60.0",
          path = vim.fn.expand("~/.local/share/jdtls/1.60.0"),
          auto_install = false,
        },
        java_test = {
          version = "0.46.0",
          path = vim.fn.expand("~/.local/share/nvim-java-extensions/java-test/0.46.0/extension"),
          auto_install = false,
        },
      })
      vim.lsp.enable("jdtls")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
