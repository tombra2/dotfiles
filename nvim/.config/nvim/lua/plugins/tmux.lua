return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  config = function()
    local function navigate(wincmd, direction)
      local previous_window = vim.api.nvim_get_current_win()
      vim.cmd("wincmd " .. wincmd)
      if vim.api.nvim_get_current_win() ~= previous_window then
        return
      end

      if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
        local herdr = vim.env.HERDR_BIN_PATH
        if not herdr or herdr == "" then
          herdr = "herdr"
        end
        vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--current" })
      elseif vim.env.TMUX and vim.env.TMUX ~= "" then
        local tmux_direction = { left = "Left", down = "Down", up = "Up", right = "Right" }
        pcall(vim.cmd, "TmuxNavigate" .. tmux_direction[direction])
      end
    end

    local mappings = {
      ["<C-h>"] = { "h", "left" },
      ["<C-j>"] = { "j", "down" },
      ["<C-k>"] = { "k", "up" },
      ["<C-l>"] = { "l", "right" },
    }

    for key, mapping in pairs(mappings) do
      vim.keymap.set("n", key, function()
        navigate(mapping[1], mapping[2])
      end, { silent = true, desc = "Navigate " .. mapping[2] .. " (vim/herdr)" })
    end

    vim.keymap.set("n", "<C-Tab>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true })
  end,
}
