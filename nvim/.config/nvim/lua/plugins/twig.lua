return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        twiggy_language_server = {
          workspace_required = true,
          settings = {
            twiggy = {
              framework = "ignore",
              phpExecutable = "php",
              symfonyConsolePath = "bin/console",
              autoInsertSpaces = true,
              inlayHints = {
                block = true,
                macro = true,
                macroArguments = true,
              },
              -- nvim-lint owns Twig-CS-Fixer diagnostics to avoid duplicates.
              diagnostics = { twigCsFixer = false },
            },
          },
          before_init = function(params, config)
            local root = type(params.rootPath) == "string" and params.rootPath or config.root_dir
            root = type(root) == "string" and root or nil
            local console = root and vim.fs.joinpath(root, "bin", "console")
            config.settings.twiggy.framework = console and vim.uv.fs_stat(console) and "symfony" or "ignore"
          end,
          on_attach = function(client)
            -- Conform owns formatting and also formats the embedded HTML.
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
      },
    },
  },
}
