local ascii = {
  [[                                                                     ]],
  [[                                                                     ]],
  [[                                                                     ]],
  [[                                                                     ]],
  [[          ____                                                       ]],
  [[         /___/\_                                                     ]],
  [[        _\   \/_/\__                                                 ]],
  [[      __\       \/_/\                             __                 ]],
  [[      \   __    __ \ \             ___    __  __ /\_\     ___ ___    ]],
  [[     __\  \_\   \_\ \ \   __     /' _ `\ /\ \/\ \\/\ \  /' __` __`\  ]],
  [[    /_/\\   __   __  \ \_/_/\    /\ \/\ \\ \ \_/ |\ \ \ /\ \/\ \/\ \ ]],
  [[    \_\/_\__\/\__\/\__\/_\_\/    \ \_\ \_\\ \___/  \ \_\\ \_\ \_\ \_\]],
  [[       \_\/_/\       /_\_\/       \/_/\/_/ \/__/    \/_/ \/_/\/_/\/_/]],
  [[          \_\/       \_\/                                            ]],
  [[                                                                     ]],
  [[                                                                     ]],
  [[                                                                     ]],
  [[                                                                     ]],
  [[                                                                     ]]
}
local db = require('dashboard')

db.custom_header = ascii
db.custom_center = {
  neovim_config = {
    desc = '    Nvim Config',
    shortcut = 'SPC e c',
    action = ':e ~/.config/nvim/'
  },
  find_history = {
    desc = 'ﭯ  Find History',
    shortcut = 'SPC r',
    command = ':Telescope oldfiles'
  },
  find_file = {
    desc = '  Find File',
    shortcut = 'SPC .',
    command = ':Telescope find_files'
  },
  find_word = {
    desc = '  Find Word',
    shortcut = 'SPC /',
    command = ':Telescope live_grep'
  },
  update_plugins = {
    desc = '  Update Plugins',
    shortcut = 'SPC u',
    command = ':PackerUpdate'
  }
}

vim.g.indentLine_fileTypeExclude = { 'dashboard' }
vim.g.dashboard_default_executive = "telescope.nvim"

-- Set git status as dashboard footer
local utils = require('telescope.utils')

local git_root, ret = utils.get_os_command_output({
  "git",
  "rev-parse",
  "--show-toplevel"
}, vim.loop.cwd())

local function get_dashboard_git_status()
  local git_cmd = { 'git', 'status', '-s', '--', '.' }
  local output = utils.get_os_command_output(git_cmd)
  db.custom_footer = { '', '', 'Git status', unpack(output) }
end

if ret ~= 0 then
  local is_worktree = utils.get_os_command_output({
    "git",
    "rev-parse",
    "--is-inside-work-tree"
  }, vim.loop.cwd())
  if is_worktree[1] == "true" then
    get_dashboard_git_status()
  else
    db.custom_footer = { '', '', '.:|  github.com/ndom91/dotfiles  |:.' }
  end
else
  get_dashboard_git_status()
end
