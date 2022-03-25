local cmd = vim.cmd

-- highlight yank for a brief second for visual feedback
cmd "autocmd! TextYankPost * lua vim.highlight.on_yank { on_visual = false }"

-- Format on save
-- cmd "autocmd! BufWritePre * FormatWrite"

-- nvim 0.7.0+ lua native autocmds? (TJdev - https://www.youtube.com/watch?v=ekMIIAqTZ34
-- vim.api.nvim_create_autocmd("BufWritePre", { command = "FormatWrite" })
cmd "autocmd! BufWritePre /opt/checkly/**/*.js EslintFixAll"
