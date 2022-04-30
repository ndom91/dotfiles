local null_ls = require("null-ls")

null_ls.setup({
  debug = true,
  sources = {
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.lua_format.with({
      extra_args = {
        "--indent-width=2",
        "--column-limit=80",
        "--no-use-tab",
        "--spaces-inside-table-braces",
        "--chop-down-table",
        "--break-after-operator",
        "--no-keep-simple-function-one-line"
      }
    }),
    null_ls.builtins.formatting.shfmt
        .with({ extra_args = { "-i", "2", "-ci" } }),
    null_ls.builtins.formatting.prettier_d_slim,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.completion.spell
  },
  on_attach = function(client)
    if client.resolved_capabilities.document_formatting then
      vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
            ]])
    end
  end
})
