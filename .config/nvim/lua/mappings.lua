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
nnoremap("<leader>.", "<cmd>Telescope find_files<CR>")
nnoremap("<leader>,", "<cmd>Telescope buffers show_all_buffers=true<CR>")
nnoremap("<leader>/", "<cmd>Telescope live_grep<CR>")
nnoremap("<leader>:", "<cmd>Telescope command_history<CR>")
nnoremap("<leader>r", "<cmd>Telescope oldfiles<CR>", { desc = "Old Files" })
nnoremap("<leader>h", "<cmd>Telescope help_tags<CR>")
nnoremap("<leader>s", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "LSP Symbols" })
nnoremap("<leader>gc", "<cmd>Telescope git_commits<CR>")
nnoremap("<leader>gb", "<cmd>Telescope git_bcommits<CR>")
nnoremap("<leader>gr", "<cmd>Telescope git_branches<CR>")
nnoremap("<leader>d", "<cmd>Telescope diagnostics<CR>")
nnoremap("<leader>e", "<cmd>Telescope diagnostics { severity: 0 }<CR>")

-- trouble
nnoremap("<leader>tr", "<cmd>TroubleToggle<cr>")

-- document-colorizer
nnoremap("<leader>lC", "<cmd>lua require('document-color').buf_toggle()<CR>")
