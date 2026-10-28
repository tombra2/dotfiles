return {
  {
    "JetBrains/intellij-lsp.nvim",
    lazy = false, -- Import Maven/Gradle projects before opening a source file.
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      colorscheme = false,
      git = false,
      data_sharing = "none",
      -- Keep consent and license activation interactive on first start.
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = { enabled = false },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
