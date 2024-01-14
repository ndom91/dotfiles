-- https://github.com/theia-ide/typescript-language-server
local is_npm_package_installed = require("utils").is_npm_package_installed

local have_vue = is_npm_package_installed "vue"

if not have_vue then
  -- require('typescript-tools').setup {}

  require("lspconfig").tsserver.setup {
    capabilities = require "plugins.lsp.capabilities",
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.documentFormattingProvider = false
    --   on_attach(client, bufnr)
    -- end,
    -- cmd = { "typescript-language-server", "--stdio" },
    -- filetypes = {
    --   "javascript",
    --   "javascriptreact",
    --   "javascript.jsx",
    --   "typescript",
    --   "typescriptreact",
    --   "typescript.tsx",
    -- },
    -- init_options = {
    --   hostInfo = "neovim",
    -- },
    -- root_dir = require("lspconfig.util").root_pattern("package.json", "package-lock.json", "tsconfig.json", "jsconfig.json", ".git"),
    -- single_file_support = true,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "literal",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  }
end
