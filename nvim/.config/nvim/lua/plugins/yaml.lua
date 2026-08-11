vim.filetype.add({
  filename = {
    ["compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
    [".gitlab-ci.yml"] = "yaml.gitlab",
  },
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github-actions",
    [".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    [".*docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
  },
})

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
          -- Microsoft Compose LSP provides richer, non-duplicated Compose diagnostics.
          filetypes = { "yaml", "yaml.gitlab", "yaml.github-actions", "yaml.helm-values" },
          settings = {
            yaml = {
              yamlVersion = "1.2",
              validate = true,
              hover = true,
              completion = true,
              customTags = {
                "!reference sequence",
                "!abstract scalar",
                "!closure scalar",
                "!php/const scalar",
                "!php/enum scalar",
                "!php/object scalar",
                "!returns_clone scalar",
                "!service scalar",
                "!tagged_iterator scalar",
                "!tagged_locator scalar",
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
