local autocmd = vim.api.nvim_create_autocmd

local cmd = vim.cmd

-- highlight yank for a brief second for visual feedback
cmd "autocmd! TextYankPost * lua vim.highlight.on_yank { on_visual = false }"

-- nvim 0.7.0+ lua native autocmds? (TJdev - https://www.youtube.com/watch?v=ekMIIAqTZ34
cmd "autocmd! CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })"

-- vim.api.nvim_create_user_command(
--   'W',
--   function(input)
--     vim.write()
--   end,
--   {bang = true}
-- )
-- 
-- autocmd("FileType", {
--   pattern = "prompt",
--   callback = function()
--     require("cmp").setup.buffer { enabled = false }
--   end
-- })
