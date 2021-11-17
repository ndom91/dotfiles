-- aliases for Lua API functions we will use a lot!
local opt = vim.opt
local o = vim.o

-- settings
vim.cmd [[
syntax on
filetype plugin indent on
]]
vim.g.mapleader = " "
vim.g.vimsyn_embed = "lPrjt"
vim.g.swapfile = false

o.autoindent = true
o.completeopt = "menu,menuone,noselect"
o.clipboard = "unnamedplus"
o.cursorline = true
o.errorbells = false
o.expandtab = true
o.foldmethod = "manual"
opt.formatoptions:append("jnrql")
opt.formatoptions:remove("2tac")
o.hidden = true
o.ignorecase = true
o.inccommand = "split"
o.incsearch = true
o.laststatus = 2
o.lazyredraw = true
o.mouse = "n"
o.number = true
o.path = ".,**"
o.relativenumber = true
o.scrolloff = 8
o.shiftwidth = 2
opt.shortmess:append("atsc")
o.showtabline = 1
o.signcolumn = "yes"
o.smartcase = true
o.smartindent = true
o.softtabstop = 2
o.splitbelow = true
o.splitright = true
o.tabstop = 2
o.termguicolors = true
o.wildignore = "*/node_modules/*,*/.git/*,DS_Store,*/venv/*,*/__pycache__/*,*.pyc"
o.wildmenu = true
o.wildmode = "full"
o.wildoptions = "pum"
o.wrap = false

-- colorscheme
vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_italic_variables = true
vim.g.tokyonight_italic_keywords = true
vim.g.tokyonight_italic_comments = true
vim.g.tokyonight_transparent = true
vim.g.tokyonight_transparent_sidebar = true
vim.g.tokyonight_lualine_bold = false
vim.cmd "colorscheme tokyonight"
