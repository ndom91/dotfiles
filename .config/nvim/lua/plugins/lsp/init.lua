local function goto_next_error() vim.diagnostic.goto_next { severity = "Error" } end
local function goto_prev_error() vim.diagnostic.goto_prev { severity = "Error" } end

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {},
    ensure_installed = {
      -- https://mason-registry.dev/registry/list
      "js-debug-adapter",
      -- "lua-language-server",
      -- -- "typescript-language-server",
      -- "bash-language-server",
      -- "css-lsp",
      -- "eslint-lsp",
      -- "eslintd",
      "prettierd",
      "rustywind",
      -- "html-lsp",
      -- "svelte-language-server",
      -- "tailwindcss-language-server",
      -- "vue-language-server",
      "shellcheck",
      "shfmt",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = { exclude = { "svelte", "tailwindcss", "css", "json", "vue", "html" } },
      ensure_installed = {
        "lua_ls",
        -- "tsserver",
        -- "js-debug-adapter",
        "bashls",
        "cssls",
        -- "eslint",
        "html",
        "svelte",
        "tailwindcss",
        -- "vue",
        "volar",
      },
      handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {}
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "b0o/schemastore.nvim",
    },
    config = function()
      ---@param results lsp.LocationLink[]
      ---@return lsp.LocationLink[]
      local function filter_out_libraries_from_lsp_items(results)
        local without_node_modules = vim.tbl_filter(
          function(item) return item.targetUri and not string.match(item.targetUri, "node_modules") end,
          results
        )

        if #without_node_modules > 0 then return without_node_modules end

        return results
      end

      ---@param results lsp.LocationLink[]
      ---@return lsp.LocationLink[]
      local function filter_out_same_location_from_lsp_items(results)
        return vim.tbl_filter(function(item)
          local from = item.originSelectionRange
          local to = item.targetSelectionRange

          return not (
            from
            and from.start.character == to.start.character
            and from.start.line == to.start.line
            and from["end"].character == to["end"].character
            and from["end"].line == to["end"].line
          )
        end, results)
      end

      ---This function is mostly copied from Telescope, I only added the
      ---`node_modules` filtering.
      local function list_or_jump(action, title, opts)
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local make_entry = require "telescope.make_entry"

        opts = opts or {}

        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, action, params, function(err, result, ctx)
          if err then
            vim.api.nvim_err_writeln("Error when executing " .. action .. " : " .. err.message)
            return
          end
          local flattened_results = {}
          if result then
            -- textDocument/definition can return Location or Location[]
            if not vim.tbl_islist(result) then flattened_results = { result } end

            vim.list_extend(flattened_results, result)
          end

          -- This is the only added step to the Telescope function
          flattened_results =
            filter_out_same_location_from_lsp_items(filter_out_libraries_from_lsp_items(flattened_results))

          local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding

          if #flattened_results == 0 then
            return
          elseif #flattened_results == 1 and opts.jump_type ~= "never" then
            local uri = params.textDocument.uri
            if uri ~= flattened_results[1].uri and uri ~= flattened_results[1].targetUri then
              if opts.jump_type == "tab" then
                vim.cmd.tabedit()
              elseif opts.jump_type == "split" then
                vim.cmd.new()
              elseif opts.jump_type == "vsplit" then
                vim.cmd.vnew()
              elseif opts.jump_type == "tab drop" then
                local file_uri = flattened_results[1].uri
                if file_uri == nil then file_uri = flattened_results[1].targetUri end
                local file_path = vim.uri_to_fname(file_uri)
                vim.cmd("tab drop " .. file_path)
              end
            end

            vim.lsp.util.jump_to_location(flattened_results[1], offset_encoding, opts.reuse_win)
          else
            local locations = vim.lsp.util.locations_to_items(flattened_results, offset_encoding)
            pickers
              .new(opts, {
                prompt_title = title,
                finder = finders.new_table {
                  results = locations,
                  entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
                },
                previewer = conf.qflist_previewer(opts),
                sorter = conf.generic_sorter(opts),
                push_cursor_on_edit = true,
                push_tagstack_on_edit = true,
              })
              :find()
          end
        end)
      end

      local function definitions(opts) return list_or_jump("textDocument/definition", "LSP Definitions", opts) end

      vim.keymap.set("n", "<Leader>lf", function()
        vim.lsp.buf.format {
          async = false,
          filter = function(client) return client.name == "null-ls" end,
        }
      end, { silent = true, noremap = true, desc = "Format" })

      -- vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "]e", goto_next_error)
      vim.keymap.set("n", "[e", goto_prev_error)

      -- local on_attach = function(client, bufnr)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(event)
          local opts = { buffer = event.buf }
          local builtin = require "telescope.builtin"

          vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          vim.keymap.set("n", "<Leader>e", builtin.diagnostics, opts)
          vim.keymap.set("n", "gr", builtin.lsp_references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
          vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gd", definitions, opts)
          -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>re", vim.lsp.buf.rename)

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight symbol references on hover
          if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
            vim.api.nvim_clear_autocmds {
              buffer = event.buf,
              group = "LspDocumentHighlight",
            }
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
        end,
      })

      require "plugins.lsp.langs.typescript"
      require "plugins.lsp.langs.vue"
      require "plugins.lsp.langs.json"
      require "plugins.lsp.langs.css"
      require "plugins.lsp.langs.html"
      require "plugins.lsp.langs.tailwindcss"
      require "plugins.lsp.langs.svelte"
      -- require 'plugins.lsp.langs.lua'

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
    "folke/neodev.nvim",
    enabled = true,
    ft = "lua",
    config = function()
      require("neodev").setup {}
      require "plugins.lsp.langs.lua"
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
      require("tailwind-sorter").setup {
        on_save_enabled = true,
        on_save_pattern = { "*.vue", "*.html", "*.js", "*.jsx", "*.ts", "*.tsx", "*.astro", "*.svelte" },
      }
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
  },
}
