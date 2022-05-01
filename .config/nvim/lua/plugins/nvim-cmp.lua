local present, cmp = pcall(require, "cmp")
local lspkind = require("lspkind")

if not present then
  vim.notify "Could not load cmp"
  return
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end
  },
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
    ["<C-y>"] = cmp.config.disable,
    ["<C-c>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = true })
  },
  formatting = {
    format = lspkind.cmp_format({ with_text = false, maxwidth = 50 })
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer", keyword_length = 2, max_item_count = 10 }
  }),
  view = { entries = "native" }
})
