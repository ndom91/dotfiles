local present, toggleterm = pcall(require, "toggleterm")

if not present then
  vim.notify "Could not load toggleterm"
  return
end

local Terminal = require("toggleterm.terminal").Terminal

toggleterm.setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 20
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<leader>tt]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 0,
  start_in_insert = true,
  persist_size = true,
  direction = "horizontal",
  close_on_exit = true,
  float_opts = {
    border = "curved",
    width = 20,
    height = 20,
    winblend = 3,
    highlights = { border = "Special", background = "Normal" }
  }
}

--[[ See 'utils/term.lua' for lazygit floating term ]]

vim.api.nvim_set_keymap("n", "<leader>lg",
                        "<cmd>lua require('utils.term')._lazygit_toggle()<CR>",
                        { noremap = true, silent = true })
