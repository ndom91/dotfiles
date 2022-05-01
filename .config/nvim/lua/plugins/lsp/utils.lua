local telescope_builtin = require("telescope.builtin")

local M = {}

local function show_diagnostics(opts)
  opts = opts or {}
  vim.diagnostic.setloclist({ open_loclist = false })
  telescope_builtin.loclist(opts)
end

local function map(type, input, output, unique_identifier, description,
                   additional_options)
  local options = { remap = true, desc = description }
  if additional_options then
    options = vim.tbl_deep_extend("force", options, additional_options)
  end

  vim.keymap.set(type, input, output, options)
end

local function noremap(type, input, output, unique_identifier, description,
                       additional_options)
  local options = { remap = false }
  if additional_options then
    options = vim.tbl_deep_extend("force", options, additional_options)
  end

  map(type, input, output, unique_identifier, description, options)
end

local function generate_buf_keymapper(bufnr)
  return function(type, input, output, unique_identifier, description,
                  extraOptions)
    local options = { buffer = bufnr }
    if extraOptions ~= nil then
      options = vim.tbl_deep_extend("force", options, extraOptions)
    end
    noremap(type, input, output, unique_identifier, description, options)
  end
end

function M.set_default_on_buffer(client, bufnr)
  local buf_set_keymap = generate_buf_keymapper(bufnr)

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  local cap = client.server_capabilities

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- gives definition & references
  -- buf_set_keymap('n','<leader>tt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  if cap.definitionProvider then
    buf_set_keymap("n", "gd", vim.lsp.buf.definition, "lsp_preview_definition",
                   "Preview definition")
  end
  -- if cap.declarationProvider then
  -- map('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- end
  if cap.implementationProvider then
    buf_set_keymap("n", "gi", vim.lsp.buf.implementation,
                   "lsp_goto_implementation", "Go to implementation")
  end

  if cap.referencesProvider then
    -- buf_set_keymap('n','<leader>tr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap("n", "gr", telescope_builtin.lsp_references,
                   "lsp_references", "Show references")
    -- buf_set_keymap('n', 'gr', '<cmd>Trouble lsp_references<cr>', 'lsp',
    --                'lsp_references', 'Show references')
  end

  if cap.hoverProvider then
    buf_set_keymap("n", "K", vim.lsp.buf.hover, "lsp_hover_docs",
                   "Hover documentation")
  end

  if cap.documentSymbolProvider then
    -- buf_set_keymap('n','<leader>to', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
    buf_set_keymap("n", "<leader>tO", telescope_builtin.lsp_document_symbols,
                   "lsp_document_symbols", "Document symbols")
    buf_set_keymap("n", "<leader>to", "<cmd>AerialToggle!<CR>",
                   "lsp_aerial_document_symbols", "(Aerial) Document symbols")
  end

  buf_set_keymap("n", "<leader>ts", vim.lsp.buf.signature_help,
                 "lsp_signature_help", "Show signature")

  -- if cap.workspaceSymbolProvider then
  --   map('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
  -- end

  if cap.codeActionProvider then
    -- buf_set_keymap('n','<leader>fa', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'lsp', 'lsp_', '')
    -- buf_set_keymap('v', '<leader>fa', "<cmd>'<,'>lua vim.lsp.buf.range_code_action()<cr>", 'lsp', 'lsp_', '')
    buf_set_keymap("n", "<leader>fa", function()
      telescope_builtin.lsp_code_actions({ timeout = 2000 })
      -- telescope_functions.lsp_code_actions({ timeout = 2000 })
    end, "lsp_code_actions", "Code actions")

    buf_set_keymap("v", "<leader>fa", function()
      telescope_builtin.lsp_range_code_actions({ timeout = 2000 })
    end, "lsp_code_actions_in_visual", "Code actions (visual)")
  end

  -- buf_set_keymap('n','<leader>fe', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  -- buf_set_keymap('n','<leader>fe', '<cmd>:LspDiagnostics 0<CR>', opts)
  buf_set_keymap("n", "<leader>fe", show_diagnostics, "lsp_show_diagnostics",
                 "Show diagnostics")

  buf_set_keymap("n", "<leader>fE", vim.diagnostic.open_float,
                 "lsp_show_line_diagnostics", "Show line diagnostics")

  buf_set_keymap("n", "[e", vim.diagnostic.goto_prev, "lsp_previous_diagnostic",
                 "Previous diagnostic")
  buf_set_keymap("n", "]e", vim.diagnostic.goto_next, "lsp_next_diagnostic",
                 "next diagnostic")

  -- when sumneko lua will be able to format we can reput the capabilities
  -- if cap.documentFormattingProvider then
  buf_set_keymap("n", "<leader>ff", vim.lsp.buf.formatting, "lsp_format",
                 "Format")
  -- elseif cap.documentRangeFormattingProvider then
  -- buf_set_keymap("n", "<leader>ff", vim.lsp.buf.formatting, "lsp_range_format", "Format")
  -- end

  if cap.renameProvider then
    buf_set_keymap("n", "<leader>fr", vim.lsp.buf.rename, "lsp_rename", "Rename")
  end

  buf_set_keymap("n", "<leader>lsc", function()
    print(vim.inspect(vim.lsp.get_active_clients()))
  end, "lsp_debug_clients", "LSP clients")

  buf_set_keymap("n", "<leader>lsl", function()
    print(vim.lsp.get_log_path())
  end, "lsp_debug_logs", "Show log path")

  buf_set_keymap("n", "<leader>lsa", ":LspInfo()<CR>", "lsp_info", "LSP Info")
end

return M
