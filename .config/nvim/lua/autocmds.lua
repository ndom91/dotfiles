local cmd = vim.cmd

-- highlight yank for a brief second for visual feedback
cmd "autocmd! TextYankPost * lua vim.highlight.on_yank { on_visual = false }"

-- Format on save
cmd "autocmd! BufWritePre * FormatWrite"
cmd "autocmd! BufWritePre *.js EslintFixAll"
