local M = {}

local nls = require "null-ls"
local nls_utils = require "null-ls.utils"
local b = nls.builtins

local with_diagnostics_code = function(builtin)
  return builtin.with { diagnostics_format = "#{m} [#{c}]" }
end

-- local with_root_file = function(builtin, file)
--   return builtin.with {
--     condition = function(utils)
--       return utils.root_has_file(file)
--     end,
--   }
-- end

local sources = {
  -- formatting
  -- NODE
  b.formatting.prettier_d_slim.with {
    extra_args = {
      "--single-quote",
      "--bracket-spacing",
      "--arrow-spacing",
      "--no-semi"
    }
  },
  b.formatting.eslint_d,
  b.formatting.shfmt.with({ extra_args = { "-i", "2", "-ci" } }),
  b.formatting.lua_format.with({
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
  -- PYTHON
  -- b.formatting.black,
  --[[ b.formatting.autopep8, ]]

  -- b.formatting.shellharden,
  -- b.formatting.fixjson,
  -- with_root_file(b.formatting.stylua, "stylua.toml"),

  -- diagnostics
  -- NODE
  b.diagnostics.eslint_d,
  b.diagnostics.tsc,
  with_diagnostics_code(b.diagnostics.shellcheck),
  -- PYTHON
  --[[ b.diagnostics.flake8, ]]

  -- b.diagnostics.write_good,
  -- b.diagnostics.markdownlint,
  -- b.diagnostics.codespell,
  -- b.diagnostics.zsh,
  -- b.diagnostics.stylelint,

  -- code actions
  b.code_actions.gitsigns.with { disabled_filetypes = { "NeogitCommitMessage" } },
  b.code_actions.eslint_d,
  b.code_actions.shellcheck,
  -- b.code_actions.gitrebase,
  -- b.code_actions.refactoring,
  -- b.code_actions.proselint,

  -- hover
  -- b.hover.dictionary,
}

function M.setup(opts)
  nls.setup {
    -- debug = true,
    debounce = 150,
    save_after_format = false,
    sources = sources,
    on_attach = opts.on_attach,
    root_dir = nls_utils.root_pattern ".git"
  }
end

return M
