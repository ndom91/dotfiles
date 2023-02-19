return {
  "nvim-telescope/telescope.nvim",
  config = function()
local previewers = require("telescope.previewers")
local Job = require("plenary.job")

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  -- Don't preview files over 10mb - https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > 100000 then
      return
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
  -- Don't preview binaries
  Job:new({
    command = "file",
    args = { "--mime-type", "-b", filepath },
    on_exit = function(j)
      local mime_type = vim.split(j:result()[1], "/")[1]
      if mime_type == "text" then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      else
        -- maybe we want to write something to the buffer here
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
      end
    end
  }):sync()
end

    require("telescope").setup {
      defaults = {
        buffer_previewer_maker = new_maker,
        mappings = { i = {}, n = { ["<C-c>"] = "delete_buffer" } },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--hidden",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim"
          -- "--multiline",
          -- "--multiline-dotall"
        },
        file_ignore_patterns = {
          "pnpm-lock.yaml",
          "package-lock.json",
          "node_modules",
          ".next",
          "static",
          "coverage",
          "lcov-report",
          "dist",
          "pack/github",
          ".nuxt",
          ".docusaurus",
          "build"
        },
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = { 'png', 'jpg' } -- Supported image formats
              local split_path = vim.split(filepath:lower(), '.', { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local image = require('hologram.image'):new(filepath, {})
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, image)
            else
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
            end
          end
        },
      },
      pickers = {
        -- find_files = { find_command = { "fd", "--type", "f", "--strip-cwd-prefix" } },
        -- apps = { find_command = { "fd", "--type", "f", "--strip-cwd-prefix" } },
        dotfiles = { find_command = { "fd", "--type", "f", ".", "/home/ndo/.dotfiles" } }
      },
      extensions = { "ui-select" }
    }

    require "plugins.telescope"
  end
}
