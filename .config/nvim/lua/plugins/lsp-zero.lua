-- See:https://github.com/JoosepAlviste/dotfiles/blob/master/config/nvim/lua/j/plugins/lsp/null_ls.lua

-- local function allow_format(servers)
--   return function(client)
--     return vim.tbl_contains(servers, client.name)
--   end
-- end

local function goto_next_error()
  vim.diagnostic.goto_next({ severity = "Error" })
end

local function goto_prev_error()
  vim.diagnostic.goto_prev({ severity = "Error" })
end

vim.lsp.buf.rename = {
  float = function()
    local curr_name = vim.fn.expand("<cword>")
    local tshl = require("nvim-treesitter-playground.hl-info").get_treesitter_hl()
    if tshl and #tshl > 0 then
      local ind = tshl[#tshl]:match("^.*()%*%*.*%*%*")
      tshl = tshl[#tshl]:sub(ind + 2, -3)
    end

    local win = require("plenary.popup").create(curr_name, {
      title = "New Name",
      style = "minimal",
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      relative = "cursor",
      borderhighlight = "FloatBorder",
      titlehighlight = "Title",
      highlight = tshl,
      focusable = true,
      width = 25,
      height = 1,
      line = "cursor+2",
      col = "cursor-1",
    })

    local map_opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(0, "i", "<Esc>", "<cmd>stopinsert | q!<CR>", map_opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>stopinsert | q!<CR>", map_opts)
    vim.api.nvim_buf_set_keymap(
      0,
      "i",
      "<CR>",
      "<cmd>stopinsert | lua vim.lsp.buf.rename.apply('" .. curr_name .. "'," .. win .. ")<CR>",
      map_opts
    )
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<CR>",
      "<cmd>stopinsert | lua vim.lsp.buf.rename.apply('" .. curr_name .. "'," .. win .. ")<CR>",
      map_opts
    )
  end,
  apply = function(curr, win)
    local newName = vim.trim(vim.api.nvim_get_current_line())
    vim.api.nvim_win_close(win, true)
    if #newName > 0 and newName ~= curr then
      local params = vim.lsp.util.make_position_params()
      params.newName = newName
      vim.lsp.buf_request(0, "textDocument/rename", params)
    end
  end,
}

return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v2.x",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },
    {
      "williamboman/mason.nvim",
      build = function()
        pcall(vim.cmd, "MasonUpdate")
      end,
    },
    { "williamboman/mason-lspconfig.nvim" },
    { "b0o/schemastore.nvim" },
    { "jose-elias-alvarez/null-ls.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" }, -- Snippets
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" }, -- Languages
    { "jose-elias-alvarez/typescript.nvim" },
    { "folke/neodev.nvim" }, -- lua support for nvim config + development
  },
  config = function()
    local lsp = require("lsp-zero").preset({})
    local lspconfig = require("lspconfig")

    local formatting_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    lsp.on_attach(function(client, bufnr)
      lsp.default_keymaps({ buffer = bufnr })
      local bind = vim.keymap.set
      local builtin = require("telescope.builtin")

      -- Autoformatting
      -- vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   group = formatting_augroup,
      --   buffer = bufnr,
      --   callback = function()
      --     vim.lsp.buf.format({
      --       bufnr = bufnr,
      --       -- filter = function(buf_client)
      --       --   return buf_client.name == "null-ls"
      --       -- end,
      --     })
      --   end,
      -- })

      -- Highlight symbol references on hover
      if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
        vim.api.nvim_clear_autocmds({
          buffer = bufnr,
          group = "LspDocumentHighlight",
        })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          group = "LspDocumentHighlight",
          buffer = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = "LspDocumentHighlight",
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
      end

      bind({ "n", "x" }, "<leader>lf", function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          async = false,
          timeout_ms = 10000,
          -- group = formatting_augroup,
          -- filter = allow_format({ "null-ls" }),
        })
      end)
      bind("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction", buffer = true })
      bind("n", "<leader>re", vim.lsp.buf.rename.float, { desc = "[Re]name", buffer = true })

      bind("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition", buffer = true })
      bind("n", "gD", vim.lsp.buf.type_definition, { desc = "[G]oto Type [D]efinition", buffer = true })
      bind("n", "gr", builtin.lsp_references, { desc = "[G]oto [R]eferences", buffer = true })
      bind("n", "gI", vim.lsp.buf.implementation, { desc = "[G]oto [I]mplementation", buffer = true })
      bind("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "[D]ocument [S]ymbols", buffer = true })
      bind("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, { desc = "[W]orkspace [S]ymbols", buffer = true })

      -- Navigate diagnostics
      bind("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic", buffer = true })
      bind("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic", buffer = true })
      bind("n", "<leader>dd", builtin.diagnostics, { desc = "List Diagnostics", buffer = true })

      bind("n", "]e", goto_next_error, { desc = "Next Error", buffer = true })
      bind("n", "[e", goto_prev_error, { desc = "Prev Error", buffer = true })

      bind("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation", buffer = true })
      bind("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Documentation", buffer = true })
    end)

    lspconfig.jsonls.setup({ settings = { json = { schemas = require("schemastore").json.schemas() } } })

    lspconfig.yamlls.setup({
      schemastore = { enable = true },
      settings = {
        yaml = {
          hover = true,
          completion = true,
          validate = true,
          schemas = require("schemastore").json.schemas(),
        },
      },
    })

    lsp.ensure_installed({
      -- "tsserver",
      "html",
      "jsonls",
      "dockerls",
      "bashls",
      "vimls",
      "tailwindcss",
      -- "lua_ls",
      "cssls",
      "volar",
      "yamlls",
    })

    -- Disable a specific server
    -- lsp.skip_server_setup({'eslint'})

    -- Setup neovim lua configuration
    require("neodev").setup()
    -- require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
    -- lsp.nvim_workspace() -- lsp-zero lua language server setup for nvim (using neodev instead)

    -- Disable semantic highlight groups in nvim 0.9+
    lsp.set_server_config({
      on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
      end,
    })

    -- lsp.format_on_save({
    --   servers = {
    --     ["lua_ls"] = { "lua" },
    --     ["null-ls"] = { "typescript", "javascript", "javascriptreact", "typescriptreact", "css", "html" },
    --   },
    -- })

    lsp.setup()

    -- typescript.nvim setup
    require("typescript").setup({
      disable_commands = false, -- prevent the plugin from creating Vim commands
      debug = false, -- enable debug logging for commands
      go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
      },
      server = {
        -- pass options to lspconfig's setup method
        on_attach = {
          disable_formatting = true,
        },
      },
    })

    -- Disable 'tsserver' syntaxhighlighting fuckups
    require("lspconfig").tsserver.setup({
      on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
      end,
    })

    -- null-ls setup
    local null_ls = require("null-ls")
    local nls_utils = require("null-ls.utils")
    local null_opts = lsp.build_options("null-ls", {})

    null_ls.setup({
      debug = true,
      -- debounce = 150,
      -- save_after_format = true,
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = formatting_augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end,
          })
        end
        null_opts.on_attach(client, bufnr)
      end,
      diagnostics_format = "#{m} [#{c}]",
      root_dir = nls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
      sources = {
        -- typescript.nvim
        require("typescript.extensions.null-ls.code-actions"),

        -- null-ls builtins - https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
        -- Code Actions
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.code_actions.shellcheck,
        -- Formatting
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.stylua.with({
          extra_args = { "--indent-type=Spaces", "--indent-width=2" },
        }),
        -- null_ls.builtins.formatting.lua_format.with({extra_args = {'--tab-width=2', '--column-limit=100'}}),
        null_ls.builtins.formatting.shfmt,
        -- Diagnostics
        -- null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.shellcheck,
        -- null_ls.builtins.diagnostics.pyright,
        -- Python
        null_ls.builtins.diagnostics.pylint.with({
          diagnostics_postprocess = function(diagnostic)
            diagnostic.code = diagnostic.message_id
          end,
        }),
        null_ls.builtins.formatting.black.with({
          extra_args = { "--line-length=120" },
        }),
        null_ls.builtins.formatting.isort,
      },
    })

    local cmp = require("cmp")
    local cmp_action = require("lsp-zero").cmp_action()

    cmp.setup({
      preselect = "item",
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
      },
      sources = {
        { name = "copilot" },
        { name = "nvim_lsp", max_item_count = 20 },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip", keyword_length = 2 },
        { name = "treesitter" },
        { name = "buffer", max_item_count = 5, keyword_length = 3 },
        { name = "path" },
        { name = "nvim_lua" },
      },
      -- formatting = {
      --   fields = { "abbr", "kind", "menu" },
      --   format = require("lspkind").cmp_format({
      --     preset = "codicons",
      --     mode = "symbol_text", -- show text + symbol annotations
      --     maxwidth = 50, -- prevent the popup from showing more than provided characters
      --     ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
      --   }),
      -- },
      -- window = {
      --   completion = cmp.config.window.bordered(),
      --   documentation = cmp.config.window.bordered(),
      -- },
      window = {
        completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          col_offset = -3,
          side_padding = 0,
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local kind =
            require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50, preset = "codicons" })(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          kind.menu = "    (" .. (strings[2] or "") .. ")"

          return kind
        end,
      },
    })

    --   local cmp = require("cmp")
    --   local luasnip = require("luasnip")
    --   local lsp = require("lsp-zero").preset({
    --     name = "minimal",
    --     set_lsp_keymaps = true,
    --     manage_nvim_cmp = true,
    --     suggest_lsp_servers = true,
    --     cmp_capabilities = true,
    --     -- setup_servers_on_start = true,
    --   })
    --
    --   lsp.setup_nvim_cmp({
    --     snippet = {
    --       expand = function(args)
    --         luasnip.lsp_expand(args.body)
    --       end,
    --     },
    --     mapping = cmp.mapping.preset.insert({
    --       ["<C-p>"] = cmp.mapping.scroll_docs(-4),
    --       ["<C-n>"] = cmp.mapping.scroll_docs(4),
    --       ["<C-Space>"] = cmp.mapping.complete({}),
    --       ["<CR>"] = cmp.mapping.confirm({
    --         behavior = cmp.ConfirmBehavior.Replace,
    --         select = true,
    --       }),
    --       ["<Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_next_item()
    --         elseif luasnip.expand_or_jumpable() then
    --           luasnip.expand_or_jump()
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       ["<S-Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_prev_item()
    --         elseif luasnip.jumpable(-1) then
    --           luasnip.jump(-1)
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --     }),
    --     sources = {
    --       { name = "copilot" },
    --       { name = "nvim_lsp", max_item_count = 10 },
    --       { name = "nvim_lsp_signature_help" },
    --       { name = "luasnip" },
    --       { name = "treesitter" },
    --       { name = "buffer", max_item_count = 5 },
    --       { name = "path" },
    --       { name = "nvim_lua" },
    --     },
    --     formatting = {
    --       format = function(entry, vim_item)
    --         -- Kind icons
    --         -- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind],
    --         --                               vim_item.kind) -- This concatonates the icons with the name of the item kind
    --
    --         -- copilot
    --         if entry.source.name == "copilot" then
    --           vim_item.kind = "[] Copilot"
    --           vim_item.kind_hl_group = "CmpItemKindCopilot"
    --           return vim_item
    --         end
    --
    --         -- Source
    --         vim_item.menu = ({
    --           nvim_lsp = "[LSP]",
    --           luasnip = "[Snip]",
    --           buffer = "[Buffer]",
    --           nvim_lua = "[Lua]",
    --           treesitter = "[Treesitter]",
    --           path = "[Path]",
    --           nvim_lsp_signature_help = "[Signature]",
    --         })[entry.source.name]
    --
    --         return vim_item
    --       end,
    --     },
    --     window = {
    --       documentation = {
    --         border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    --         winhighlight = "NormalFloat:NormalFloat,FloatBorder:TelescopeBorder",
    --       },
    --     },
    --   })
    --
    --   vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    --
    --   lsp.ensure_installed({
    --     "tsserver",
    --     "html",
    --     "jsonls",
    --     "dockerls",
    --     "bashls",
    --     "vimls",
    --     "tailwindcss",
    --     -- "lua_ls",
    --     "cssls",
    --     "volar",
    --     "yamlls",
    --   })
    --
    --   lsp.configure("jsonls", { settings = { json = { schemas = require("schemastore").json.schemas() } } })
    --
    --   lsp.configure("yamlls", {
    --     schemastore = { enable = true },
    --     settings = {
    --       yaml = {
    --         hover = true,
    --         completion = true,
    --         validate = true,
    --         schemas = require("schemastore").json.schemas(),
    --       },
    --     },
    --   })
    --
    --   lsp.configure("tsserver", {
    --     disable_formatting = true,
    --     settings = {
    --       javascript = {
    --         inlayHints = {
    --           includeInlayEnumMemberValueHints = true,
    --           includeInlayFunctionLikeReturnTypeHints = true,
    --           includeInlayFunctionParameterTypeHints = true,
    --           includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
    --           includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    --           includeInlayPropertyDeclarationTypeHints = true,
    --           includeInlayVariableTypeHints = true,
    --         },
    --       },
    --       typescript = {
    --         inlayHints = {
    --           includeInlayEnumMemberValueHints = true,
    --           includeInlayFunctionLikeReturnTypeHints = true,
    --           includeInlayFunctionParameterTypeHints = true,
    --           includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
    --           includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    --           includeInlayPropertyDeclarationTypeHints = true,
    --           includeInlayVariableTypeHints = true,
    --         },
    --       },
    --     },
    --   })
    --
    --   local formatting_augroup = vim.api.nvim_create_augroup("lspformatting", {})
    --
    --   lsp.on_attach(function(client, bufnr)
    --     local bind = vim.keymap.set
    --     local builtin = require("telescope.builtin")
    --
    --     -- Autoformatting
    --     vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
    --     vim.api.nvim_create_autocmd("BufWritePre", {
    --       group = formatting_augroup,
    --       buffer = bufnr,
    --       callback = function()
    --         vim.lsp.buf.format({
    --           bufnr = bufnr,
    --           filter = function(buf_client)
    --             return buf_client.name == "null-ls"
    --           end,
    --         })
    --       end,
    --     })
    --
    --     -- Highlight symbol references on hover
    --     if client.server_capabilities.documentHighlightProvider then
    --       vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
    --       vim.api.nvim_clear_autocmds({
    --         buffer = bufnr,
    --         group = "LspDocumentHighlight",
    --       })
    --       vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    --         group = "LspDocumentHighlight",
    --         buffer = bufnr,
    --         callback = vim.lsp.buf.document_highlight,
    --       })
    --       vim.api.nvim_create_autocmd("CursorMoved", {
    --         group = "LspDocumentHighlight",
    --         buffer = bufnr,
    --         callback = vim.lsp.buf.clear_references,
    --       })
    --     end
    --
    --     bind(
    --       "n",
    --       "<leader>lf",
    --       "<cmd>lua vim.lsp.buf.format({ timeout_ms = 2000 })<CR>",
    --       { desc = "Format Buffer", buffer = bufnr }
    --     )
    --     bind("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction", buffer = bufnr })
    --     bind("n", "<leader>re", vim.lsp.buf.rename.float, { desc = "[Re]name", buffer = bufnr })
    --
    --     bind("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition", buffer = bufnr })
    --     bind("n", "gD", vim.lsp.buf.type_definition, { desc = "[G]oto Type [D]efinition", buffer = bufnr })
    --     bind("n", "gr", builtin.lsp_references, { desc = "[G]oto [R]eferences", buffer = bufnr })
    --     bind("n", "gI", vim.lsp.buf.implementation, { desc = "[G]oto [I]mplementation", buffer = bufnr })
    --     bind("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "[D]ocument [S]ymbols", buffer = bufnr })
    --     bind("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, { desc = "[W]orkspace [S]ymbols", buffer = bufnr })
    --
    --     -- Navigate diagnostics
    --     bind("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic", buffer = bufnr })
    --     bind("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic", buffer = bufnr })
    --     bind("n", "<leader>dd", builtin.diagnostics, { desc = "List Diagnostics", buffer = bufnr })
    --
    --     bind("n", "[e", goto_next_error, { desc = "Next Error", buffer = bufnr })
    --     bind("n", "]e", goto_prev_error, { desc = "Prev Error", buffer = bufnr })
    --
    --     bind("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation", buffer = bufnr })
    --     bind("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Documentation", buffer = bufnr })
    --   end)
    --
    --   -- Setup neovim lua configuration
    --   require("neodev").setup()
    --   -- lsp.nvim_workspace() -- lsp-zero lua language server setup for nvim (using neodev instead)
    --
    --   lsp.setup()
    --
    --   -- null-ls setup
    --   local null_ls = require("null-ls")
    --   local nls_utils = require("null-ls.utils")
    --   local null_opts = lsp.build_options("null-ls", {})
    --
    --   null_ls.setup({
    --     -- debug = true,
    --     -- debounce = 150,
    --     -- save_after_format = true,
    --     diagnostics_format = "#{m} [#{c}]",
    --     root_dir = nls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
    --     on_attach = function(client, bufnr)
    --       if client.supports_method("textDocument/formatting") then
    --         vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
    --         vim.api.nvim_create_autocmd("BufWritePre", {
    --           group = formatting_augroup,
    --           buffer = bufnr,
    --           callback = function()
    --             vim.lsp.buf.format({ bufnr = bufnr })
    --           end,
    --         })
    --       end
    --       null_opts.on_attach(client, bufnr)
    --     end,
    --     sources = {
    --       -- null-ls builtins - https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
    --       -- Code Actions
    --       null_ls.builtins.code_actions.eslint_d,
    --       null_ls.builtins.code_actions.shellcheck,
    --       -- Formatting
    --       null_ls.builtins.formatting.eslint_d,
    --       null_ls.builtins.formatting.stylua.with({
    --         extra_args = { "--indent-type=Spaces", "--indent-width=2" },
    --       }),
    --       -- null_ls.builtins.formatting.lua_format.with({extra_args = {'--tab-width=2', '--column-limit=100'}}),
    --       null_ls.builtins.formatting.shfmt,
    --       -- Diagnostics
    --       null_ls.builtins.diagnostics.eslint_d,
    --       null_ls.builtins.diagnostics.shellcheck,
    --       null_ls.builtins.diagnostics.pyright,
    --       -- Python
    --       null_ls.builtins.diagnostics.pylint.with({
    --         diagnostics_postprocess = function(diagnostic)
    --           diagnostic.code = diagnostic.message_id
    --         end,
    --       }),
    --       null_ls.builtins.formatting.black.with({
    --         extra_args = { "--line-length=120" },
    --       }),
    --       null_ls.builtins.formatting.isort,
    --     },
    --   })
  end,
}
