return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "olimorris/neotest-phpunit",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}

    local adapters = {
      require("neotest-phpunit")({
        phpunit_cmd = function()
          return vim.fn.stdpath("config") .. "/bin/ddev-phpunit"
        end,
        env = {
          PHP_CS_FIXER_IGNORE_ENV = "1",
        },
        filter_dirs = { ".git", "node_modules", "vendor", "var" },
      }),
    }

    -- neotest-java requires jdtls; do not start it alongside IntelliJ LSP.

    vim.list_extend(opts.adapters, adapters)

    opts.consumers = opts.consumers or {}
    opts.consumers.notify = function(client)
      client.listeners.results = function(adapter_id, results, partial)
        if partial then
          return
        end
        local passed, failed = 0, 0
        for _, result in pairs(results) do
          if result.status == "passed" then
            passed = passed + 1
          elseif result.status == "failed" then
            failed = failed + 1
          end
        end
        vim.schedule(function()
          if failed > 0 then
            vim.notify(string.format(" %d failed, %d passed", failed, passed), vim.log.levels.ERROR, { title = "Tests" })
          else
            vim.notify(string.format(" %d passed", passed), vim.log.levels.INFO, { title = "Tests" })
          end
        end)
      end
      return {}
    end
  end,
}
