-- aliases
local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.vimsyn_embed = "lPrjt"
vim.g.swapfile = false
vim.api.nvim_set_var('markdown_fenced_languages', {
  "html",
  "javascript",
  "vim",
  "css",
  "javascriptreact",
  "typescript",
  "yaml"
})

opt.completeopt = "menu,menuone,noselect"
opt.clipboard = "unnamedplus"

opt.cursorline = true
local group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = function()
      vim.opt_local.cursorline = value
    end
  })
end

set_cursorline("WinLeave", false)
set_cursorline("WinEnter", true)
set_cursorline("FileType", false, "TelescopePrompt")

opt.breakindent = true
opt.showbreak = string.rep(" ", 3)
opt.linebreak = true

opt.belloff = "all"
opt.expandtab = true
opt.equalalways = false
opt.formatoptions:append("jn")
opt.formatoptions:remove("2a")
opt.hidden = true
opt.ignorecase = true
opt.inccommand = "split"
opt.incsearch = true
opt.laststatus = 3
opt.lazyredraw = true
opt.mouse = "n"
opt.number = true
opt.path = ".,**"
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.shortmess:append("atsc")
opt.shortmess:remove("S")
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.wildignore =
".next,node_modules,.git/,DS_Store,venv*,__pycache__,*pycache*,*.pyc,tmp,temp"
opt.wildmenu = true
opt.wildmode = "longest:full"
opt.pumblend = 17
opt.wildoptions = "pum"
opt.wrap = true
