return {
  "nvim-telescope/telescope.nvim",
  config = function()
    local previewers = require("telescope.previewers")
    local actions = require("telescope.actions")
    local Job = require("plenary.job")

    local new_maker = function(filepath, bufnr, opts)
      opts = opts or {}

      filepath = vim.fn.expand(filepath)
      -- Don't preview files over 10mb - https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
      vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then
          return
        end
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
          if (mime_type == "text") or (j:result()[1] == "application/json") then
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          else
            -- maybe we want to write something to the buffer here
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
            end)
          end
        end,
      }):sync()
    end

    require("telescope").setup({
      defaults = {
        buffer_previewer_maker = new_maker,
        prompt_prefix = "  ",
        selection_caret = " ",
        entry_prefix = "  ",
        set_env = { ["COLORTERM"] = "truecolor" },
        color_devicons = true,
        path_dispay = { shorten = 2 },
        results_title = "",
        prompt_title = "Search",
        winblend = 0,
        border = {},
        mappings = {
          i = {
            ["<esc>"] = actions.close,
            ["<c-j>"] = actions.move_selection_next,
            ["<c-k>"] = actions.move_selection_previous,
            ["<s-up>"] = actions.cycle_history_prev,
            ["<s-down>"] = actions.cycle_history_next,
            ["<C-c>"] = "delete_buffer",
            ["<C-w>"] = function()
              vim.api.nvim_input("<c-s-w>")
            end,
          },
          n = {
            ["q"] = actions.close,
            ["<C-c>"] = "delete_buffer",
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--hidden",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim",
          -- "--multiline",
          -- "--multiline-dotall"
        },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_ignore_patterns = {
          "%.jpg",
          "%.jpeg",
          "%.png",
          "%.otf",
          "%.ttf",
          "%.lock",
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
          "build",
        },
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = { "png", "jpg" } -- Supported image formats
              local split_path = vim.split(filepath:lower(), ".", { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local image = require("hologram.image"):new(filepath, {})
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, image)
            else
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
            end
          end,
        },
      },
      pickers = {
        live_grep = { prompt_title = "Grep", preview_title = "Results" },
        find_files = { prompt_title = "Files", preview_title = "Results" },
        old_files = { prompt_title = "Recents", preview_title = "Results" },
        -- apps = { find_command = { "fd", "--type", "f", "--strip-cwd-prefix" } },
        dotfiles = { find_command = { "fd", "--type", "f", ".", "/home/ndo/.dotfiles" } },
      },
      extensions = { "ui-select" },
    })
  end,
}
