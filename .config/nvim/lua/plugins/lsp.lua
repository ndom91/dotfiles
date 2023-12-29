local function goto_next_error() vim.diagnostic.goto_next { severity = 'Error' } end
local function goto_prev_error() vim.diagnostic.goto_prev { severity = 'Error' } end

vim.keymap.set('n', '<Leader>lf', function()
  vim.lsp.buf.format {
    async = false,
    filter = function(client)
      local current_bufnr = vim.fn.bufnr '%'
      local current_buffer_path = vim.api.nvim_buf_get_name(current_bufnr)
      -- For Checkly directories force 'eslint' as formatter
      if string.find(current_buffer_path, '/opt/checkly') then
        return client.name == "eslint"
      else
        return true
      end
    end
  }
end, { silent = true, noremap = true, desc = "Format" })

vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', ']e', goto_next_error)
vim.keymap.set('n', '[e', goto_prev_error)

local on_attach = function(client, bufnr)
  local builtin = require 'telescope.builtin'
  local opts = { buffer = bufnr }

  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('n', '<Leader>e', builtin.diagnostics, opts)
  vim.keymap.set('n', 'gr', builtin.lsp_references, opts)

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help)
  vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<space>re', vim.lsp.buf.rename)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)

  -- Highlight symbol references on hover
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup('LspDocumentHighlight', { clear = false })
    vim.api.nvim_clear_autocmds {
      buffer = bufnr,
      group = 'LspDocumentHighlight',
    }
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = 'LspDocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = 'LspDocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- Autoformatting
  if client.supports_method 'textDocument/formatting' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format {
          async = false,
          filter = function(client)
            local current_bufnr = vim.fn.bufnr '%'
            local current_buffer_path = vim.api.nvim_buf_get_name(current_bufnr)
            -- For Checkly directories force 'eslint' as formatter
            if string.find(current_buffer_path, '/opt/checkly') then
              return client.name == "eslint"
            else
              return true
            end
          end
        }
      end
    })
  end
end

return {
  {
    'folke/neodev.nvim',
    opts = {}
  },
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'js-debug-adapter',
        'lua-language-server',
        'typescript-language-server',
        'bash-language-server',
        'css-lsp',
        'eslint-lsp',
        'eslintd',
        'html-lsp',
        'svelte-language-server',
        'tailwindcss-language-server',
        'vue-language-server',
        'shellcheck',
        'shfmt',
      }
    }
  },
  -- {
  --   'williamboman/mason-lspconfig.nvim',
  --   opts = {
  --     automatic_installation = true,
  --     ensure_installed = languages,
  --   },
  -- },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      "b0o/schemastore.nvim",
    },
    config = function()
      require('neodev').setup {}
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities(),
        {
          workspace = {
            -- PERF didChangeWatchedFiles is too slow.
            -- TODO Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
            didChangeWatchedFiles = { dynamicRegistration = false },
          },
        }
      )

      local lspconfig = require 'lspconfig'

      for _, language in pairs({
        'html',
        'cssls',
        -- 'tsserver',
        -- 'eslint',
        'pyright',
        'gopls',
        'tailwindcss',
        -- 'volar',
        'bashls',
        'dockerls',
        'lua_ls',
        'svelte'
      }) do
        lspconfig[language].setup {
          capabilities = capabilities,
          on_attach = on_attach,
        }
      end

      lspconfig.eslint.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        format = true,
        settings = {
          format = true,
        },
        root_dir = function(...)
          return require("lspconfig.util").root_pattern(".git")(...)
        end,
      }

      lspconfig.volar.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        init_options = {
          configFiles = {
            vetur = {
              useWorkspaceDependencies = true,
              validation = {
                template = true,
                style = true,
                script = true,
                templateProps = true,
              },
              completion = {
                autoImport = true,
                tagCasing = "kebab",
                scaffoldSnippetSources = {
                  workspace = true,
                  user = true,
                },
              },
            },
          },
        },
      }

      lspconfig.jsonls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
          }
        }
      }

      lspconfig.tsserver.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
        end,
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        init_options = {
          hostInfo = "neovim",
        },
        -- root_dir = require("lspconfig.util").root_pattern("package.json", "package-lock.json", "tsconfig.json", "jsconfig.json", ".git"),
        single_file_support = true,
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


      -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      --   border = "single",
      -- })
      -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      --   border = "single",
      --   focusable = false,
      --   relative = "cursor",
      -- })


      -- vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      --   virtual_text = false,
      -- })
    end,
  },
  {
    'laytan/tailwind-sorter.nvim',
    enabled = true,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
    },
    build = 'cd formatter && npm i && npm run build',
    config = function()
      require('tailwind-sorter').setup {
        on_save_enabled = true,
        on_save_pattern = { '*.vue', '*.html', '*.js', '*.jsx', '*.ts', '*.tsx', '*.astro', '*.svelte' },
      }
    end,
  },
  {
    'sbdchd/neoformat',
    enabled = false
  },
  {
    'stevearc/conform.nvim',
    enabled = false
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        }
      }
    },
  },
}
