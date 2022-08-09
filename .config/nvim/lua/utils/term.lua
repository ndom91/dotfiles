local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local git_tui = "lazygit"
-- local git_tui = "gitui"

local git_client = Terminal:new{
  cmd = git_tui,
  dir = "git_dir",
  size = 40,
  float_opts = {
    border = "double",
    width = 160,
    height = 60,
    winblend = 0,
    highlights = { border = "Special", background = "Normal" }
  },
  hidden = true,
  direction = "float",
}

function M.git_client_toggle()
  git_client:toggle()
end

return M
