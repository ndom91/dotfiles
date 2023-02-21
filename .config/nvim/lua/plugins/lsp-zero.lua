return {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v1.x',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { "lvimuser/lsp-inlayhints.nvim" },
    { 'b0o/schemastore.nvim' },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },

    -- Snippets
    { 'L3MON4D3/LuaSnip' },
    { 'rafamadriz/friendly-snippets' },

    -- Languages
    { 'jose-elias-alvarez/typescript.nvim' },
    { "folke/neodev.nvim" } -- lua support for nvim config + development
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require("luasnip")
    local lsp = require('lsp-zero').preset({
      name = 'minimal',
      set_lsp_keymaps = true,
      manage_nvim_cmp = true,
      suggest_lsp_servers = true,
      cmp_capabilities = true,
      -- setup_servers_on_start = true,
    })

    -- lsp.nvim_workspace() -- lsp-zero lua language server setup for nvim (using neodev instead)
    lsp.setup_nvim_cmp({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-p>'] = cmp.mapping.scroll_docs( -4),
        ['<C-n>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable( -1) then
            luasnip.jump( -1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = {
        { name = "copilot" },
        { name = "nvim_lsp",               max_item_count = 10 },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip" },
        { name = "treesitter" },
        { name = "buffer",                 max_item_count = 5 },
        { name = "path" },
        { name = "nvim_lua" }
      },
      formatting = {
        format = function(entry, vim_item)
          -- Kind icons
          -- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind],
          --                               vim_item.kind) -- This concatonates the icons with the name of the item kind

          -- copilot
          if entry.source.name == "copilot" then
            vim_item.kind = "[] Copilot"
            vim_item.kind_hl_group = "CmpItemKindCopilot"
            return vim_item
          end

          -- Source
          vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                buffer = "[Buffer]",
                nvim_lua = "[Lua]",
                treesitter = "[Treesitter]",
                path = "[Path]",
                nvim_lsp_signature_help = "[Signature]"
              })[entry.source.name]

          return vim_item
        end
      },
      window = {
        documentation = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "NormalFloat:NormalFloat,FloatBorder:TelescopeBorder"
        }
      }
    })

    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

    lsp.ensure_installed({
      'tsserver',
      'html',
      'jsonls',
      'dockerls',
      'bashls',
      'vimls',
      'tailwindcss',
      'lua_ls',
      'cssls',
      'volar',
      'yamlls'
    })

    lsp.configure('jsonls', {
      settings = {
        json = { schemas = require("schemastore").json.schemas() }
      }
    })

    lsp.configure('yamlls', {
      schemastore = { enable = true },
      settings = {
        yaml = {
          hover = true,
          completion = true,
          validate = true,
          schemas = require("schemastore").json.schemas()
        }
      }
    })

    lsp.configure('tsserver', {
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
    })

    lsp.on_attach(function(client, bufnr)
      local opts = { buffer = bufnr }
      local bind = vim.keymap.set

      local formatting_augroup = vim.api.nvim_create_augroup('LspFormatting', {})

      local formatting_disabled_ls = { 'volar', 'intelephense', 'tsserver' }
      if client.supports_method 'textDocument/formatting' and not vim.tbl_contains(formatting_disabled_ls, client.name) then
        vim.api.nvim_clear_autocmds { group = formatting_augroup, buffer = bufnr }
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = formatting_augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format {
              filter = function(buf_client)
                return not vim.tbl_contains(formatting_disabled_ls, buf_client.name)
              end,
            }
          end,
        })
      end
      bind('n', '<leader>lf', '<cmd>LspZeroFormat<cr>', opts)
      bind('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      bind('n', '<leader>re', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      -- more keybindings...

      bind('n', 'gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition', buffer = bufnr })
      bind('n', 'gr', require('telescope.builtin').lsp_references, { desc = '[G]oto [R]eferences', buffer = bufnr })
      bind('n', 'gI', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation', buffer = bufnr })
      bind('n', '<leader>D', vim.lsp.buf.type_definition, { desc = 'Type [D]efinition', buffer = bufnr })
      bind('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols,
        { desc = '[D]ocument [S]ymbols', buffer = bufnr })
      bind('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
        { desc = '[W]orkspace [S]ymbols', buffer = bufnr })

      -- See `:help K` for why this keymap
      bind('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation', buffer = bufnr })
      bind('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature Documentation', buffer = bufnr })
    end)

    lsp.skip_server_setup({ 'prettierd' })


    -- local on_attach = function(_, bufnr)
    --   local nmap = function(keys, func, desc)
    --     if desc then
    --       desc = 'LSP: ' .. desc
    --     end
    --
    --     vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    --   end
    --
    --   nmap('<leader>lf', 'LspZeroFormat', '[R]e[n]ame')
    --   nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    --   nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    --
    --   nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    --   nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    --   nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    --   nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    --   nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    --   nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    --
    --   -- See `:help K` for why this keymap
    --   nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    --   nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    --
    --   -- Lesser used LSP functionality
    --   -- nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    --   -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    --   -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    --   -- nmap('<leader>wl', function()
    --   --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    --   -- end, '[W]orkspace [L]ist Folders')
    --
    --   -- Create a command `:Format` local to the LSP buffer
    --   vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    --     vim.lsp.buf.format()
    --   end, { desc = 'Format current buffer with LSP' })
    -- end

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. They will be passed to
    --  the `settings` field of the server config. You must look up that documentation yourself.
    local servers = {
      -- clangd = {},
      -- gopls = {},
      -- pyright = {},
      -- rust_analyzer = {},
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
      html = {},
      jsonls = {
        settings = {
          json = { schemas = require("schemastore").json.schemas() }
        }

      },
      dockerls = {},
      bashls = {},
      vimls = {},
      tailwindcss = {},
      cssls = {},
      volar = {},
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

      },
      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    }

    -- Setup neovim lua configuration
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    --
    -- -- Setup mason so it can manage external tooling
    -- require('mason').setup()
    --
    -- -- Ensure the servers above are installed
    -- local mason_lspconfig = require 'mason-lspconfig'
    --
    -- mason_lspconfig.setup {
    --   ensure_installed = vim.tbl_keys(servers),
    -- }
    --
    -- mason_lspconfig.setup_handlers {
    --   function(server_name)
    --     require('lspconfig')[server_name].setup {
    --       capabilities = capabilities,
    --       on_attach = on_attach,
    --       settings = servers[server_name],
    --     }
    --   end,
    -- }

    lsp.setup()
  end
}
