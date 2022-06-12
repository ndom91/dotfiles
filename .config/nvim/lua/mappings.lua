---------------------
-- BUILTIN ACTIONS --
---------------------
-- move lines up/down
nnoremap("<A-j>", ":m .+1<CR>==")
nnoremap("<A-k>", ":m .-2<CR>==")
inoremap("<A-j>", "j<Esc>:m .+1<CR>==gi")
inoremap("<A-k>", "j<Esc>:m .-2<CR>==gi")
vnoremap("<A-j>", ":m '>+1<CR>gv=gv")
vnoremap("<A-k>", ":m '<-2<CR>gv=gv")

-- keep line centered on search/join
nnoremap("n", "nzz")
nnoremap("N", "Nzz")
nnoremap("J", "mzJ`z")

-- window movement
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")

-- resizing splits
nnoremap("<C-Up>", ":resize +2<cr>")
nnoremap("<C-Down>", ":resize -2<cr>")
nnoremap("<C-Left>", ":vertical resize +2<cr>")
nnoremap("<C-Right>", ":vertical resize -2<cr>")

-- remap Y to yank to end of line
nnoremap("Y", "y$")
vnoremap("Y", "y$")

-- break undo chain
inoremap(".", ".<c-g>u")
inoremap(",", ",<c-g>u")
inoremap("!", "!<c-g>u")
inoremap("?", "?<c-g>u")

-- delete text without yanking
nnoremap("<leader>d", '"_d')
vnoremap("<leader>d", '"_d')

-- turn off search highlighting
nnoremap("<enter>", ":nohlsearch<cr>")

-- neovim terminal can exit to normal mode with <esc> now
tnoremap("<esc>", [[<c-\><c-n>]])

-- disable keys
nnoremap("<c-z>", "<Nop>") -- disable ctrl-z suspend
nnoremap("Q", "<Nop>") -- disable ex mode

--------------------
-- PLUGIN ACTIONS --
--------------------

-- Telescope
nnoremap("<leader>.", "<cmd>Telescope find_files prompt_prefix=🔍<CR>")
nnoremap("<leader>,",
         "<cmd>Telescope buffers show_all_buffers=true prompt_prefix=🔍<CR>")
nnoremap("<leader>/", "<cmd>Telescope live_grep prompt_prefix=🔍<CR>")
nnoremap("<leader>:", "<cmd>Telescope command_history prompt_prefix=🔍<CR>")
nnoremap("<leader>r", "<cmd>Telescope oldfiles prompt_prefix=🔍<CR>")
nnoremap("<leader>h", "<cmd>Telescope help_tags prompt_prefix=🔍<CR>")
nnoremap("gD", "<cmd>Telescope lsp_type_definitions prompt_prefix=🔍<CR>")
nnoremap("gd", "<cmd>Telescope lsp_definitions prompt_prefix=🔍<CR>")
nnoremap("gi", "<cmd>Telescope lsp_implementations prompt_prefix=🔍<CR>")
nnoremap("gr", "<cmd>Telescope lsp_references prompt_prefix=🔍<CR>")
nnoremap("<leader>so",
         "<cmd>Telescope lsp_document_symbols prompt_prefix=🔍<CR>")
nnoremap("<leader>gc", "<cmd>Telescope git_commits prompt_prefix=🔍<CR>")
nnoremap("<leader>gb", "<cmd>Telescope git_branches prompt_prefix=🔍<CR>")

-- Buffers
nnoremap("<c-x>",
         '<cmd>lua require("bufferline").handle_close(vim.fn.bufnr("%"))<CR>')
nnoremap("<Tab>", ":bnext<CR>")
nnoremap("<S-Tab>", ":bprev<CR>")

-- nvim-tree
nnoremap("<c-n>", "<cmd>NvimTreeToggle<CR>")

-- trouble
nnoremap("<leader>tr", "<cmd>TroubleToggle<cr>")
