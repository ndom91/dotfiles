return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope-ui-select.nvim',
  },
  keys = {
    { "<leader>.",  "<cmd>Telescope find_files<CR>",                    { desc = "Telescope files" } },
    { "<leader>,",  "<cmd>Telescope buffers show_all_buffers=true<CR>", { desc = "Telescope buffers" } },
    { "<leader>/",  "<cmd>Telescope live_grep<CR>",                     { desc = "Telescope grep" } },
    { "<leader>:",  "<cmd>Telescope command_history<CR>" },
    { "<leader>r",  "<cmd>Telescope oldfiles<CR>",                      { desc = "Old Files" } },
    { "<leader>h",  "<cmd>Telescope help_tags<CR>",                     { desc = "All Help" } },
    { "<leader>s",  "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "LSP Symbols" } },
    { "<leader>gc", "<cmd>Telescope git_commits<CR>" },
    { "<leader>gb", "<cmd>Telescope git_bcommits<CR>" },
    { "<leader>gr", "<cmd>Telescope git_branches<CR>" },
    { "<leader>d",  "<cmd>Telescope diagnostics<CR>",                   { desc = "Show all diagnostics" } },
    { "<leader>e",  "<cmd>Telescope diagnostics { severity: 0 }<CR>",   { desc = "Show only errors" } },
  },
  config = function()
    local actions = require 'telescope.actions'

    local file_ignore_patterns = {
      '%.jpg',
      '%.jpeg',
      '%.png',
      '%.otf',
      '%.ttf',
      '%.lock',
      'pnpm-lock.yaml',
      'package-lock.json',
      '^node_modules/',
      '^\\.next/',
      '^static/',
      '^coverage/',
      '^lcov-report/',
      '^dist/',
      '^pack/github/',
      '^\\.nuxt/',
      '^\\.docusaurus/',
      '^build/',
      '[.]svelte-kit/',
    }

    require('telescope').setup {
      defaults = {
        preview = {
          filesize_limit = 10, -- MB
        },
        prompt_prefix = '  ',
        selection_caret = ' ',
        entry_prefix = '  ',
        set_env = { ['COLORTERM'] = 'truecolor' },
        color_devicons = true,
        -- path_dispay = { shorten = 2 },
        -- path_display = function(_, path)
        --   local filename = path:gsub(vim.pesc(vim.loop.cwd()) .. '/', ''):gsub(vim.pesc(vim.fn.expand '$HOME'), '~')
        --   local tail = require('telescope.utils').path_tail(filename)
        --   return string.format('%s — %s', tail, filename)
        -- end,
        results_title = '',
        prompt_title = 'Search',
        winblend = 0,
        border = {},
        mappings = {
          i = {
            ['<esc>'] = actions.close,
            ['<c-j>'] = actions.move_selection_next,
            ['<c-k>'] = actions.move_selection_previous,
            ['<s-up>'] = actions.cycle_history_prev,
            ['<s-down>'] = actions.cycle_history_next,
            ['<C-c>'] = actions.delete_buffer + actions.move_to_top,
            ['<C-d>'] = actions.delete_buffer + actions.move_to_top,
            ['<C-w>'] = function()
              vim.api.nvim_input '<c-s-w>'
            end,
          },
          n = {
            ['q'] = actions.close,
            ['<C-c>'] = actions.delete_buffer + actions.move_to_top,
          },
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          -- '--hidden',
          -- '--ignore',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--trim',
          -- "--multiline",
          -- "--multiline-dotall"
        },
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'bottom',
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
        -- dynamic_preview_title = true,
      },
      pickers = {
        live_grep = {
          prompt_title = 'Grep',
          preview_title = 'Results',
          path_display = { 'smart' },
          dynamic_preview_title = true,
          file_ignore_patterns,
        },
        find_files = {
          prompt_title = 'Files',
          preview_title = 'Results',
          file_ignore_patterns,
        },
        old_files = {
          prompt_title = 'Recents',
          preview_title = 'Results',
          sort_lastused = true,
          cwd_only = true
        },
        -- apps = { find_command = { "fd", "--type", "f", "--strip-cwd-prefix" } },
        dotfiles = { find_command = { 'fd', '--type', 'f', '.', '/home/ndo/.dotfiles' } },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown {},
        },
        fzf = {
          fuzzy = true,                   -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true,    -- override the file sorter
          case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        }
      },
    }
    require('telescope').load_extension('ui-select')
    require('telescope').load_extension('fzf')
  end,
}
