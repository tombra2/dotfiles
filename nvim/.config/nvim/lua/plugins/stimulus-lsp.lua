return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "stimulus-language-server" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        stimulus_ls = {
          filetypes = { "html", "ruby", "eruby", "blade", "php", "twig" },
        },
      },
    },
  },
}
