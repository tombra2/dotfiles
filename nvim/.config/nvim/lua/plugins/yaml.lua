-- YAML: LSP (yaml-language-server + SchemaStore) comes from the
-- lazyvim.plugins.extras.lang.yaml extra; Docker/Compose LSP from
-- lazyvim.plugins.extras.lang.docker. This file only fills the gaps.
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "yamlfmt", "yamllint" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              -- Compose files are validated by docker-compose-langserver;
              -- yamlls would only duplicate (and disagree on) those errors.
              schemas = {
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
                  "docker-compose*.y*ml",
                  "compose*.y*ml",
                },
              },
              keyOrdering = false,
              format = { enable = false }, -- conform/yamlfmt owns formatting
            },
          },
        },
      },
    },
  },
}
