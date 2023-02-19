local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  dir = "git_dir",
  size = 40,
  float_opts = {
    border = "double",
    width = 160,
    height = 60,
    winblend = 0,
    highlights = { border = "Special", background = "Normal" }
  }
})

function M._lazygit_toggle()
  lazygit:toggle()
end

return M
