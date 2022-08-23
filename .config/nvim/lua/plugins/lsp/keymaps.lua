local M = {}

local keymap = vim.keymap.set

local function keymappings(client, bufnr)
  local opts = { noremap = true, silent = true }

  -- Key mappings
  keymap("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
  keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  keymap("n", "[e",
         "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>",
         opts)
  keymap("n", "]e",
         "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>",
         opts)

  -- LSP
  keymap("n", "<leader>lR", "<cmd>Trouble lsp_references<cr>", opts)
  -- keymap("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  keymap("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", opts)
  keymap("n", "<leader>lf", "<cmd>Lspsaga lsp_finder<CR>", opts)
  keymap("n", "<leader>li", "<cmd>LspInfo<CR>", opts)
  keymap("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)
  keymap("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", opts)
  -- keymap("n", "<leader>lt","<cmd>TroubleToggle document_diagnostics<CR>", opts)
  keymap("n", "<leader>lL", "<cmd>lua vim.lsp.codelens.refresh()<CR>", opts)
  keymap("n", "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<CR>", opts)
  keymap("n", "<leader>lD",
         "<cmd>lua require('plugins.lsp').toggle_diagnostics()<CR>", opts)

  if client.server_capabilities.documentFormattingProvider then
    keymap("n", "<leader>llF",
           "<cmd>lua vim.lsp.buf.format({async = false})<CR>", opts)
  end

  -- Goto
  -- keymap("n", "gd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opts)
  keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
  -- keymap("n", "gb", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", opts)
end

function M.setup(client, bufnr)
  keymappings(client, bufnr)
end

return M
