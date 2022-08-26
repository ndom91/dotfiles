local M = {}

-- Servers from: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
local servers = {
  html = {},
  jsonls = {
    settings = { json = { schemas = require("schemastore").json.schemas() } }
  },
  dockerls = {},
  bashls = {},
  tsserver = {
    disable_formatting = true,
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true
        }
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true
        }
      }
    }
  },
  vimls = {},
  tailwindcss = {},
  cssls = {},
  veturls = {}, -- vue
  --[[ vue_language_server = {}, -- vue ]]
  lua_language_server = {},
  yamlls = {
    schemastore = { enable = true },
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        schemas = require("schemastore").json.schemas()
      }
    }
  }
  -- gopls = {},
  -- pyright = {
  --   analysis = {
  --     typeCheckingMode = "off",
  --   },
  -- },
  -- pylsp = {}, -- Integration with rope for refactoring - https://github.com/python-rope/pylsp-rope
  -- rust_analyzer = {
  --   settings = {
  --     ["rust-analyzer"] = {
  --       cargo = { allFeatures = true },
  --       checkOnSave = {
  --         command = "clippy",
  --         extraArgs = { "--no-deps" },
  --       },
  --     },
  --   },
  -- },
  -- sumneko_lua = {
  --   settings = {
  --     Lua = {
  --       runtime = {
  --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
  --         version = "LuaJIT",
  --         -- Setup your lua path
  --         path = vim.split(package.path, ";"),
  --       },
  --       diagnostics = {
  --         -- Get the language server to recognize the `vim` global
  --         globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins" },
  --         -- disable = { "lowercase-global", "undefined-global", "unused-local", "unused-vararg", "trailing-space" },
  --       },
  --       workspace = {
  --         -- Make the server aware of Neovim runtime files
  --         library = {
  --           [vim.fn.expand "$VIMRUNTIME/lua"] = true,
  --           [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
  --         },
  --         -- library = vim.api.nvim_get_runtime_file("", true),
  --         maxPreload = 2000,
  --         preloadFileSize = 50000,
  --       },
  --       completion = { callSnippet = "Both" },
  --       telemetry = { enable = false },
  --     },
  --   },
  -- },
  -- graphql = {},
  -- omnisharp = {},
  -- emmet_ls = {},
  -- marksman = {},
}

function M.on_attach(client, bufnr)
  -- Enable completion triggered by <C-X><C-O>
  -- See `:help omnifunc` and `:help ins-completion` for more information.
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or
                                           vim.lsp.buf.formatting, {
    desc = 'Format current buffer with LSP'
  })
  -- Use LSP as the handler for formatexpr.
  -- See `:help formatexpr` for more information.
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")

  -- Configure key mappings
  require("plugins.lsp.keymaps").setup(client, bufnr)

  -- Configure highlighting
  require("plugins.lsp.highlighter").setup(client, bufnr)

  -- Configure formatting
  require("plugins.lsp.null-ls.formatters").setup(client, bufnr)

  -- tagfunc
  if client.server_capabilities.definitionProvider then
    vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
  end
  
  -- inlay-hints
  --[[ local ih = require "lsp-inlayhints" ]]
  --[[ ih.on_attach(client, bufnr) ]]
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
  -- dynamicRegistration = false,
  lineFoldingOnly = true
}
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" }
}

M.capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities) -- for nvim-cmp

local opts = {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  flags = { debounce_text_changes = 150 }
}

-- Setup LSP handlers
require("plugins.lsp.handlers").setup()

function M.setup()
  -- null-ls
  require("plugins.lsp.null-ls").setup(opts)

  -- Installer
  require("plugins.lsp.installer").setup(servers, opts)
end

local diagnostics_active = true

function M.toggle_diagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end

-- function M.remove_unused_imports()
--   vim.diagnostic.setqflist { severity = vim.diagnostic.severity.WARN }
--   vim.cmd "packadd cfilter"
--   vim.cmd "Cfilter /main/"
--   vim.cmd "Cfilter /The import/"
--   vim.cmd "cdo normal dd"
--   vim.cmd "cclose"
--   vim.cmd "wa"
-- end

return M
