vim.g.dashboard_custom_header = {
  '  ',
  '  ',
  '  ',
  '  ',
  '  ',
  '  ',
  '                     ``        `````````````````````````````                                   ',
  '                    :md-     .ymNNNNNNNNNNNNNNNNNNNNNNNNNmdhy+/.`                              ',
  '                  `oNNNNo`   sNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmy/.                           ',
  '                 :dNNNNNNh.  +NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNh+`                        ',
  '               `oNNNNNNNNNm+  :mNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNs.                      ',
  '              -hNNNNNNNNNNNNh- .yNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmo.                    ',
  '            `oNNNNNNNNNNNNNNNm+` /mNNNNNNNNNNNNNoooooooosymNNNNNNNNNNNNNNNd/                   ',
  '           `hNNNNNNNNNNNNNNNNNNy. .hNNNNNNNNNNNNo`        `./sdNNNNNNNNNNNNNo                  ',
  '           /NNNNNNNNNNNNNNNNNNNNm+ `+mNNNNNNNNNNNd-           `:hNNNNNNNNNNNNo                 ',
  '           /NNNNNNNNNNNNNNNNNNNNNNy` -hNNNNNNNNNNNN+`           `/hNNNNNNNNNNNo                ',
  '           /NNNNNNNNNNomNNNNNNNNNNNd/ `+NNNNNNNNNNNNy-            `sNNNNNNNNNNN-               ',
  '           /NNNNNNNNNN..hNNNNNNNNNNNNs` -dNNNNNNNNNNNm+`            sNNNNNNNNNNd               ',
  '           /NNNNNNNNNN. `omNNNNNNNNNNNd: .oNNNNNNNNNNNNy.            yNNNNNNNNNN:              ',
  '           /NNNNNNNNNN.   -dNNNNNNNNNNNNo` :mNNNNNNNNNNNm/           -NNNNNNNNNNo              ',
  '           /NNNNNNNNNN.     sNNNNNNNNNNNNh- `sNNNNNNNNNNNNs`          yNNNNNNNNNy              ',
  '           /NNNNNNNNNN.      -hNNNNNNNNNNNN+  :mNNNNNNNNNNNm:         sNNNNNNNNNh              ',
  '           /NNNNNNNNNN.       `sNNNNNNNNNNNNh- `sNNNNNNNNNNNNs`       yNNNNNNNNNy              ',
  '           /NNNNNNNNNN.         :mNNNNNNNNNNNN+  /mNNNNNNNNNNNm-     -NNNNNNNNNNo              ',
  '           /NNNNNNNNNN.          `sNNNNNNNNNNNNy. .sNNNNNNNNNNNN+`   yNNNNNNNNNN:              ',
  '           /NNNNNNNNNN.            :dNNNNNNNNNNNm+  /mNNNNNNNNNNNh.`sNNNNNNNNNNd               ',
  '           /NNNNNNNNNN.             `yNNNNNNNNNNNNy. .yNNNNNNNNNNNmhNNNNNNNNNNN-               ',
  '           /NNNNNNNNNN.              `/mNNNNNNNNNNNm: `+NNNNNNNNNNNNNNNNNNNNNNo                ',
  '           /NNNNNNNNNN.                .hNNNNNNNNNNNNy. -hNNNNNNNNNNNNNNNNNNNo                 ',
  '           `sNNNNNNNNN.                 `+mNNNNNNNNNNNmh+/hNNNNNNNNNNNNNNNNN+                  ',
  '             /mNNNNNNN.                   -hNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNd:                   ',
  '              .sNNNNNN.                     +NNNNNNNNNNNNNNNNNNNNNNNNNNNNNy`                   ',
  '                /mNNNN.                      :dNNNNNNNNNNNNNNNNNNNNNNNNNNNNh-                  ',
  '                 .yNNN.                       `oNNNNNNNNNNNNNNNNNNNNNNNNNNNNN+                 ',
  '                   +NN.                         -hNNNNNNNNNNNNNNNydNNNNNNNNNNNy.               ',
  '                    .h.                           .+hdmNNmdhyo:.  `sdmmmmmmmmmmd-',
  '  ',
  '  ',
  '  ',
  '  ',
  '  ',
}
vim.g.indentLine_fileTypeExclude = { 'dashboard' }
vim.g.dashboard_default_executive = "telescope.nvim"
vim.g.dashboard_custom_section = {
  neovim_config = {
    description = {'  Nvim Config                SPC e c'}, 
    command = ':e ~/.config/nvim/'
  },
  find_history = {
    description = {'ﭯ Find History               SPC r'}, 
    command = ':Telescope oldfiles'
  },
  find_file = {
    description = {'  Find File                 SPC .'}, 
    command = ':Telescope find_files'
  },
  find_word = {
    description = {'  Find Word                 SPC /'}, 
    command = ':Telescope live_grep'
  },
  update_plugins = {
    description = {"  Update Plugins            SPC u"},
    command = ":PackerUpdate"
  },
}

-- Set git status as dashboard footer
local utils = require('telescope.utils')
local set_var = vim.api.nvim_set_var

local git_root, ret = utils.get_os_command_output({ "git", "rev-parse", "--show-toplevel" }, vim.loop.cwd())

local function get_dashboard_git_status()
  local git_cmd = {'git', 'status', '-s', '--', '.'}
  local output = utils.get_os_command_output(git_cmd)
  set_var('dashboard_custom_footer', {'Git status', '', unpack(output)})
end

if ret ~= 0 then
  local is_worktree = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" }, vim.loop.cwd())
  if is_worktree[1] == "true" then
    get_dashboard_git_status()
  else
    set_var('dashboard_custom_footer', { '  ', '  ', '  ', '.:|  ndo.dev  |:.' })
  end
else
    get_dashboard_git_status()
end
