return {
  {
    "JetBrains/intellij-lsp.nvim",
    lazy = false, -- Import Maven/Gradle projects before opening a source file.
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      colorscheme = false,
      git = false,
      data_sharing = "none",
      -- Blink handles completion and <CR>, not Neovim's native popup menu.
      autotrigger = false,
      word_triggers = false,
      enter_accepts_completion = false,
      completeopt = false,
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
