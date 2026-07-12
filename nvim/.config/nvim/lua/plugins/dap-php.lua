return {
  "mfussenegger/nvim-dap",
  optional = true,
  config = function()
    local dap = require("dap")

    dap.adapters.php = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/php-debug-adapter",
    }

    dap.configurations.php = {
      {
        type = "php",
        request = "launch",
        name = "Listen for Xdebug",
        port = 9003,
      },
      {
        type = "php",
        request = "launch",
        name = "Listen for Xdebug (Docker)",
        port = 9003,
        pathMappings = {
          ["/var/www/html"] = "${workspaceFolder}",
        },
      },
    }
  end,
}
