-- local fn = vim.fn
-- local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
-- if fn.empty(fn.glob(install_path)) > 0 then
--   packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
-- end
--
-- -- autoreload when editing init.lua
-- local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
-- vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = '~/.config/nvim/**/*.lua' })

-- make sure that globals.lua is required first, as we want to use the
-- functions and helpers we add there EVERYWHERE in our configuration
require 'globals'

-- everything else here, the order *shouldn't* matter as much I prefer to put
-- plugins as far towards the end of my require statements so that if you
-- introduce a bug on accident, its likely that the rest of your config works
-- fine other than some plugin configuration that is going awry
require 'settings'
require('plugins').setup()
require 'mappings'
require 'autocmds'
