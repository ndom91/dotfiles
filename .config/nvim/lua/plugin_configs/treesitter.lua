require("nvim-treesitter.configs").setup {
  context_commentstring = {
    enable = true,
    enable_autocmd = false
  },
  highlight = {
    enable = true,
    use_languagetree = false
  },
  refactor = {
    highlight_definitions = { enable = true },
    highlight_current_scope = { enable = false },
    smart_rename = {
      enable = false,
      keymaps = {
        -- mapping to rename reference under cursor
        smart_rename = "grr"
      }
    },
    navigation = {
      enable = false,
      keymaps = {
        goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
        list_definitions = "gnD" -- mapping to list all definitions in current file
      }
    }
  },
  indent = {
    enable = true
  },
  ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "graphql",
    "html",
    "http",
    "javascript",
    "json",
    "jsdoc",
    "lua",
    "make",
    "markdown",
    "python",
    "prisma",
    "query",
    "rust",
    "svelte",
    "tsx",
    "typescript",
    "scss",
    "vue",
    "yaml"
  }
}
