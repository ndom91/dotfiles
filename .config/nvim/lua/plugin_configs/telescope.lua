require("telescope").setup {
  defaults = {
    mappings = {
      i = {},
      n = {
        ["<C-c>"] = "delete_buffer"
      }
    },
    file_ignore_patterns = {"node_modules", ".next", "static", "lcov-report", "dist", "pack/github"}
  },
  pickers = {},
  extensions = {
    "ui-select"
  }
}
