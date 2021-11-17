require("telescope").setup {
  defaults = {
    mappings = {
      i = {},
      n = {
        ["<C-c>"] = "delete_buffer"
      }
    }
  },
  pickers = {},
  extensions = {}
}
