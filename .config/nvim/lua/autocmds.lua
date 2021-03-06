local cmd = vim.cmd

-- highlight yank for a brief second for visual feedback
cmd "autocmd! TextYankPost * lua vim.highlight.on_yank { on_visual = false }"

-- nvim 0.7.0+ lua native autocmds? (TJdev - https://www.youtube.com/watch?v=ekMIIAqTZ34
cmd "autocmd! CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })"
