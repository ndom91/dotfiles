return {
  "neovim/nvim-lspconfig",
  config = function()
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        local bufnr = event.buf

        local opts = {
          noremap = true,
          silent = true
        }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        vim.keymap.set({ "n", "x" }, "<leader>lf", function()
          vim.lsp.buf.format({
            -- bufnr = bufnr,
            -- async = false,
            timeout_ms = 10000,
            -- filter = function(buf_client)
            --   return buf_client.name == "null-ls"
            -- end,
            -- group = formatting_augroup,
            -- filter = allow_format({ "null-ls" }),
          })
        end)
      end
    })

    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {
        -- "lua_ls",
        -- "tsserver",
        "astro",
        "html",
        "jsonls",
        "dockerls",
        "bashls",
        "vimls",
        "tailwindcss",
        "cssls",
        "volar",
        "yamlls",
      }
    })

    local lspconfig = require('lspconfig')

    -- Format on save
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    local lsp_format_on_save = function(bufnr)
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = augroup,
        buffer = bufnr,
        -- filter = function(client)
        --   return client.name == "null-ls"
        -- end,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end

    local luasnip = require("luasnip")
    local cmp = require("cmp")

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
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        -- ["<C-g>"] = cmp.mapping(function(fallback)
        --   vim.api.nvim_feedkeys(
        --     vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<Tab>", true, true, true)),
        --     "n",
        --     true
        --   )
        -- end),
      },
      experimental = {
        ghost_text = false, -- feature conflicts with copilot.nvim's preview
      },
      sources = {
        -- { name = "copilot" },
        -- { name = "nvim_lsp", max_item_count = 20 },
        {
          name = "nvim_lsp",
          max_item_count = 20,
          entry_filter = function(entry, ctx)
            -- Don't return file paths from nvim_lsp, use 'path' source instead
            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "File"
          end,
        },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip",                keyword_length = 2 },
        { name = "treesitter" },
        { name = "buffer",                 max_item_count = 5, keyword_length = 3 },
        { name = "path" },
        { name = "nvim_lua" },
      },
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

          -- -- copilot
          -- if entry.source.name == "copilot" then
          --   kind.kind = "[] Copilot"
          --   kind.kind_hl_group = "CmpItemKindCopilot"
          --   return kind
          -- end
          --
          -- -- Source
          -- kind.menu = ({
          --   nvim_lsp = "[LSP]",
          --   luasnip = "[Snip]",
          --   buffer = "[Buffer]",
          --   nvim_lua = "[Lua]",
          --   treesitter = "[Treesitter]",
          --   path = "[Path]",
          --   nvim_lsp_signature_help = "[Signature]",
          -- })[entry.source.name]

          return kind
        end,
      },
    })

    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local get_servers = require('mason-lspconfig').get_installed_servers

    for _, server_name in ipairs(get_servers()) do
      lspconfig[server_name].setup({
        on_attach = lsp_format_on_save,
        capabilities = lsp_capabilities,
      })
    end
  end,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "b0o/schemastore.nvim",
    "jose-elias-alvarez/null-ls.nvim",
    "hrsh7th/cmp-nvim-lua", -- Snippets
    "jose-elias-alvarez/typescript.nvim",
    "folke/neodev.nvim",    -- lua support for nvim config + development
  },
}
