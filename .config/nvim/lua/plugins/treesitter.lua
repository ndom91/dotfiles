local present, treesitter_configs = pcall(require, "nvim-treesitter.configs")

if not present then
  vim.notify "Could not load nvim-treesitter.configs"
  return
end

treesitter_configs.setup {
  --[[ highlight = { enable = true, use_languagetree = false }, ]]
  highlight = { enable = true },
  refactor = {
    highlight_definitions = { enable = true },
    highlight_current_scope = { enable = false },
    smart_rename = {
      enable = false,
      keymaps = {
        -- mapping to rename reference under cursor
        -- smart_rename = "grr"
      }
    },
    navigation = {
      enable = false,
      keymaps = {
        -- goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
        -- list_definitions = "gnD" -- mapping to list all definitions in current file
      }
    }
  },
  indent = { enable = true },
  rainbow = { enable = true, extended_mode = true, max_file_lines = nil },
  context_commentstring = { enable = true },

  sync_install = false,
  ensure_installed = "all"
}
