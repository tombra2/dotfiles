return {
  "willfish/herdr-navigator.nvim",
  lazy = false,
  config = function()
    local options = {
      mappings = {
        left = "<C-h>",
        down = "<C-j>",
        up = "<C-k>",
        right = "<C-l>",
      },
      herdr_executable = vim.env.HERDR_BIN_PATH or "herdr",
    }

    -- LazyVim defines <M-j> and <M-k> later during startup. Install these
    -- mappings on the next event-loop tick so navigation wins.
    vim.schedule(function()
      require("herdr-navigator").setup(options)
    end)
  end,
}
