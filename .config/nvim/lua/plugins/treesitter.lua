return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "nvim-treesitter/playground",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      playground = {
        enable = false,
        disable = {},
        updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
      },
      autopairs = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      matchup = {
        enable = true,
      },
      refactor = {
        highlight_definitions = { enable = true },
        highlight_current_scope = { enable = false },
        smart_rename = {
          enable = false,
          keymaps = {
            -- mapping to rename reference under cursor
            -- smart_rename = "grr"
          },
        },
        navigation = {
          enable = false,
          keymaps = {
            -- goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
            -- list_definitions = "gnD" -- mapping to list all definitions in current file
          },
        },
      },
      indent = { enable = true },
      rainbow = { enable = true, extended_mode = true, max_file_lines = nil },
      context = {
        separator = '⎽',
      },
      -- context_commentstring = { enable = true, enable_autocmd = false },
      sync_install = false,
      ensure_installed = "all",
    })
  end,
}
