return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.lsp.config("vimfony", {
        cmd = { "vimfony" },
        filetypes = { "php", "twig", "yaml", "xml" },
        root_markers = { ".git" },
        single_file_support = true,
        before_init = function(params, config)
          local root = params.rootPath and tostring(params.rootPath)
          if root and root ~= "" then
            config.init_options = {
              roots = { "templates" },
              container_xml_path = root .. "/var/cache/dev/App_KernelDevDebugContainer.xml",
              vendor_dir = root .. "/vendor",
            }
          end
        end,
      })
      vim.lsp.enable("vimfony")
    end,
  },
}
