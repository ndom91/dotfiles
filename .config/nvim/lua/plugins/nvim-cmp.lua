local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and
             vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col)
                 :match("%s") == nil
end

local present, cmp = pcall(require, "cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

if not present then
  vim.notify "Could not load cmp"
  return
end

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  experimental = { native_menu = false, ghost_text = true },
  mapping = {
    ["<C-j>"] = cmp.mapping.select_next_item({
      behavior = cmp.SelectBehavior.Insert
    }),
    ["<C-k>"] = cmp.mapping.select_prev_item({
      behavior = cmp.SelectBehavior.Insert
    }),
    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-c>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Enter>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable()() then
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
    end, { "i", "s" })
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      maxwidth = 50,
      mode = 'symbol_text'
    })
  },
  sources = cmp.config.sources({
    { name = "copilot" },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer", keyword_length = 2, max_item_count = 10 }
  }),
  view = { entries = "custom", selection_order = "near_cursor" }
})
