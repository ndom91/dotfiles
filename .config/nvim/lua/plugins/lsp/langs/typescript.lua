-- https://github.com/theia-ide/typescript-language-server
local is_npm_package_installed = require("utils").is_npm_package_installed

local have_vue = is_npm_package_installed("vue")

if not have_vue then
  require("lspconfig").tsserver.setup({
    capabilities = require("plugins.lsp.capabilities"),
    on_attach = function(client, bufnr)
      client.server_capabilities.document_formatting = false
      -- null-ls messes with formatexpr for some reason, which messes up `gq`
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
      vim.bo[bufnr].formatexpr = nil
    end,
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
      documentFormatting = false,
      -- taken from https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  })
end
