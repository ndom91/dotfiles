local function goto_next_error() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.Error }) end
local function goto_prev_error() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.Error }) end

-- local icons = {
--   [vim.diagnostic.severity.ERROR] = " ",
--   [vim.diagnostic.severity.WARN] = " ",
--   [vim.diagnostic.severity.INFO] = " ",
--   [vim.diagnostic.severity.HINT] = "",
-- }

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
      ensure_installed = {
        "lua_ls",
        "tsserver",
        "bashls",
        "cssls",
        "html",
        "svelte",
        "tailwindcss",
        "volar",
      },
      handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup({})
        end,
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- "biome",
        "eslint_d",
        "js-debug-adapter",
        "prettierd",
        "rustywind",
        "shellcheck",
        "shfmt",
      },
      auto_update = true,
      run_on_start = true,
      debounce_hours = 12,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "b0o/schemastore.nvim",
      "folke/neodev.nvim",
      { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim" },
    },
    opts = {
      inlay_hints = { enabled = false },
    },
    config = function()
      local utils = require("plugins.lsp.utils")

      local function definitions(options)
        return utils.list_or_jump("textDocument/definition", "LSP Definitions", options)
      end

      -- Formattinggg
      local augroup = vim.api.nvim_create_augroup("Autoformat", {})

      local function is_null_ls_formatting_enabed(bufnr)
        local file_type = vim.bo[bufnr].filetype
        local generators =
          require("null-ls.generators").get_available(file_type, require("null-ls.methods").internal.FORMATTING)
        return #generators > 0
      end

      local function format(buf)
        local null_ls_sources = require("null-ls.sources")
        local ft = vim.bo[buf].filetype

        local has_null_ls = #null_ls_sources.get_available(ft, "NULL_LS_FORMATTING") > 0

        vim.lsp.buf.format({
          bufnr = buf,
          async = false,
          filter = function(client)
            -- vim.notify(client.name)
            if has_null_ls then
              -- vim.notify "has null-ls"
              return client.name == "null-ls"
            else
              return true
            end
          end,
        })
      end

      local format_on_write = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              -- if vim.b.format_on_write ~= false then format(bufnr) end
              format(bufnr)
            end,
          })
        end
      end

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "]e", goto_next_error)
      vim.keymap.set("n", "[e", goto_prev_error)

      -- On Attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(event)
          local options = { buffer = event.buf }
          local builtin = require("telescope.builtin")

          -- Enable inlay_hints on insert mode only
          -- Currently DISABLED
          local inlay_group = vim.api.nvim_create_augroup("lsp_augroup", { clear = true })
          vim.api.nvim_create_autocmd("InsertEnter", {
            buffer = event.buf,
            callback = function() vim.lsp.inlay_hint.enable(event.buf, true) end,
            group = inlay_group,
          })
          vim.api.nvim_create_autocmd("InsertLeave", {
            buffer = event.buf,
            callback = function() vim.lsp.inlay_hint.enable(event.buf, false) end,
            group = inlay_group,
          })

          vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          vim.keymap.set("n", "<Leader>e", builtin.diagnostics, options)
          vim.keymap.set("n", "gr", builtin.lsp_references, options)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
          vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, options)
          vim.keymap.set("n", "gd", definitions, options)
          -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, options)

          vim.keymap.set("n", "K", vim.lsp.buf.hover, options)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, options)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, options)
          vim.keymap.set("n", "<space>re", vim.lsp.buf.rename)
          vim.keymap.set(
            "n",
            "<Leader>lf",
            function() format(event.buf) end,
            { silent = true, noremap = true, desc = "Format" }
          )

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client ~= nil then
            format_on_write(client, vim.api.nvim_get_current_buf())

            -- if client.supports_method "textDocument/formatting" then
            --   vim.api.nvim_create_autocmd("BufWritePre", {
            --     group = event.buf.group,
            --     buffer = event.buf,
            --     callback = function()
            --       vim.lsp.buf.format {
            --         filter = function(filterClient) return filterClient.name == "null-ls" end,
            --         bufnr = event.buf,
            --       }
            --     end,
            --   })
            -- end

            if client.server_capabilities.documentFormattingProvider then
              if client.name == "null-ls" and is_null_ls_formatting_enabed(event.buf) or client.name ~= "null-ls" then
                vim.bo[event.buf].formatexpr = "v:lua.vim.lsp.formatexpr()"
              else
                vim.bo[event.buf].formatexpr = nil
              end
            end
            -- Highlight symbol references on hover
            if client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
              vim.api.nvim_clear_autocmds({
                buffer = event.buf,
                group = "LspDocumentHighlight",
              })
              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = "LspDocumentHighlight",
                buffer = event.buf,
                callback = vim.lsp.buf.document_highlight,
              })
              vim.api.nvim_create_autocmd("CursorMoved", {
                group = "LspDocumentHighlight",
                buffer = event.buf,
                callback = vim.lsp.buf.clear_references,
              })
            end

            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      require("plugins.lsp.langs.typescript")
      require("plugins.lsp.langs.vue")
      require("plugins.lsp.langs.json")
      require("plugins.lsp.langs.yaml")
      require("plugins.lsp.langs.css")
      require("plugins.lsp.langs.html")
      require("plugins.lsp.langs.tailwindcss")
      require("plugins.lsp.langs.svelte")
    end,
  },
  {
    "folke/neodev.nvim",
    enabled = true,
    ft = "lua",
    config = function()
      require("neodev").setup({})
      require("plugins.lsp.langs.lua")
    end,
  },
  {
    "laytan/tailwind-sorter.nvim",
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    build = "cd formatter && npm i && npm run build",
    config = function()
      require("tailwind-sorter").setup({
        on_save_enabled = true,
        on_save_pattern = { "*.vue", "*.html", "*.js", "*.jsx", "*.ts", "*.tsx", "*.astro", "*.svelte" },
      })
    end,
  },
  {
    "sbdchd/neoformat",
    enabled = false,
  },
  {
    "stevearc/conform.nvim",
    enabled = false,
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- if vim.lsp.inlay_hint then vim.lsp.inlay_hint.enable(bufnr, true) end
      end,
      settings = {
        tsserver_file_preferences = {
          -- Inlay Hints
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      -- settings = {
      --   tsserver_file_preferences = {
      --     -- importModuleSpecifierPreference = "non-relative",
      --     jsx_close_tag = {
      --       enable = true,
      --       filetypes = { "javascriptreact", "typescriptreact" },
      --     },
      --   },
      -- },
    },
    config = function()
      local api = require("typescript-tools.api")
      require("typescript-tools").setup({
        handlers = {
          -- 80006 = 'This may be converted to an async function' diagnostics.
          ["textDocument/publishDiagnostics"] = api.filter_diagnostics({ 80006 }),
        },
      })
    end,
  },
}
