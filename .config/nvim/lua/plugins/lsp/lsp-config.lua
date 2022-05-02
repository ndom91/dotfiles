local nvim_lsp = require "lspconfig"
local lsp_installer = require("nvim-lsp-installer")
local lsp_utils = require("plugins.lsp.utils")
local presentCmpNvimLsp, cmpNvimLsp = pcall(require, "cmp_nvim_lsp")

local on_attach = function(client, bufnr)
  lsp_utils.set_default_on_buffer(client, bufnr)
end

vim.lsp.set_log_level("error") -- 'trace', 'debug', 'info', 'warn', 'error'

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
if presentCmpNvimLsp then
  capabilities = vim.tbl_extend("keep", capabilities,
                                cmpNvimLsp.update_capabilities(capabilities))
end

-- Enable the following language servers
capabilities.textDocument.completion.completionItem.snippetSupport = true
local servers = {
  tsserver = require("plugins.lsp.servers.tsserver")(on_attach),
  jsonls = require("plugins.lsp.servers.jsonls")(on_attach, capabilities),
  yamlls = require("plugins.lsp.servers.yamlls")(capabilities),
  bashls = {},
  eslint = {},
  vuels = {},
  html = {},
  cssls = {},
  tailwindcss = {}
}

local default_lsp_config = {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = { debounce_text_changes = 200, allow_incremental_sync = true }
}

-- ensure installed
for server_name, server_config in pairs(servers) do
  local ok, server = lsp_installer.get_server(server_name)
  -- Check that the server is supported in nvim-lsp-installer
  if ok then
    local merged_config = vim.tbl_deep_extend("force", default_lsp_config,
                                              server_config)
    server:setup(merged_config)

    if not server:is_installed() then
      print("Installing " .. name)
      server:install()
    end
  end
end
