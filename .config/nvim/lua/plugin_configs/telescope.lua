local previewers = require("telescope.previewers")

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(
    filepath,
    function(_, stat)
      if not stat then
        return
      end
      if stat.size > 100000 then
        return
      else
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end
    end
  )
end

require("telescope").setup {
  defaults = {
    buffer_previewer_maker = new_maker,
    mappings = {
      i = {},
      n = {
        ["<C-c>"] = "delete_buffer"
      }
    },
    file_ignore_patterns = {"node_modules", ".next", "static", "coverage", "lcov-report", "dist", "pack/github"}
  },
  pickers = {
    find_files = {
      find_command = {"fd", "--type", "f", "--strip-cwd-prefix"}
    }
  },
  extensions = {
    "ui-select"
  }
}

require("telescope").load_extension("ui-select")

