local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.vimsyn_embed = "lPrjt"

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.g.skip_ts_context_commentstring_module = true

vim.api.nvim_set_var("markdown_fenced_languages", {
  "html",
  "javascript",
  "vim",
  "css",
  "javascriptreact",
  "typescript",
  "yaml",
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
    end,
  })
end

set_cursorline("WinLeave", false)
set_cursorline("WinEnter", true)
set_cursorline("FileType", false, "TelescopePrompt")

opt.breakindent = true
opt.linebreak = true

opt.signcolumn = "yes"
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
opt.lazyredraw = false
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

opt.wildignorecase = true
opt.wildignore:append("**/node_modules/*")
opt.wildignore:append("**/.git/*")
opt.wildignore:append("**/.next/*")
opt.wildignore:append("**/venv/*")
opt.wildmenu = true
opt.wildmode = "longest:full"

opt.pumblend = 17
opt.wildoptions = "pum"
opt.wrap = true
