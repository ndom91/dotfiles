return {
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',
  {
    'lvimuser/lsp-inlayhints.nvim',
    config = true
  },

  {
    'tami5/lspsaga.nvim',
    enabled = false,
    config = true
  },

  -- icons on completion
  'onsails/lspkind-nvim',

  -- lsp function signature help on wildmenu
  {
    'ray-x/lsp_signature.nvim',
    opts = {
      -- hint_enable = false,
      -- transparency = 30,
      floating_window = false,
      bind = true,
      -- shadow_blend = 36,
      -- handler_opts = { border = "rounded" },
    }
  },
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
      integration = {
        ["nvim-tree"] = {
          enable = true,
        },
      },
      progress = {
        display = {
          progress_icon = {
            pattern = "dots",
            period = 1
          }
        },
      },
      notification = {
        window = {
          winblend = 0,
        },
      },
    }
  },
  {
    'folke/trouble.nvim',
    enabled = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>tr', "<cmd>TroubleToggle<cr>", { desc = " Toggle Trouble" } },
    },
    config = true,
  },
  -- ui elements
  {
    'MunifTanjim/nui.nvim',
    enabled = true,
  },
  -- tailwind token colorizer
  {
    'mrshmllow/document-color.nvim',
    enabled = false,
    keys = {
      { "<leader>lC", "require('document-color').buf_toggle()" },
    },
    config = function()
      local docColors = require 'document-color'
      docColors.setup { mode = 'background' }
      docColors.buf_attach()
    end,
  },
  -- terminal image viewer
  {
    'edluffy/hologram.nvim',
    enabled = false,
    config = function()
      require('hologram').setup { auto_display = true }
    end,
  },
  -- cmp based copilot
  {
    'zbirenbaum/copilot.lua',
    enabled = true,
    event = "VeryLazy",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        javascript = true,
        typescript = true,
        typescriptreact = true,
        javascriptreact = true,
        lua = true,
        bash = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
            -- disable for .env files
            return false
          end
          return true
        end,
        ["."] = false,
      },
    }
  },
  -- first-party github copilot plugin
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    enabled = false,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = true,
    main = 'ibl',
    opts = {
      exclude = {
        filetypes = {
          'alpha',
          'neo-tree',
          'lsp-installer',
          'lazy',
          'packer',
          'dashboard',
        },
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        char = '▏',
        show_start = false,
        show_end = false,
        highlight = {
          'IndentBlanklineIndent1',
          'IndentBlanklineIndent2',
          'IndentBlanklineIndent3',
          'IndentBlanklineIndent4',
          'IndentBlanklineIndent5',
          'IndentBlanklineIndent6',
        },
      },
      indent = {
        char = '▏',
        highlight = {
          'IndentBlanklineIndent1',
          'IndentBlanklineIndent2',
          'IndentBlanklineIndent3',
          'IndentBlanklineIndent4',
          'IndentBlanklineIndent5',
          'IndentBlanklineIndent6',
        },
      },
    },
    config = function()
      vim.cmd [[highlight IndentBlanklineIndent6 guifg=#E0DEF4 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent5 guifg=#908CAA gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#524F67 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent3 guifg=#403d42 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guifg=#25233A gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent1 guifg=#21202E gui=nocombine]]

      -- Hide first line
      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    end,
  },
  {
    'RRethy/nvim-base16',
    enabled = false,
  },
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = false,
        RRGGBBAA = true,
        css = true,
        tailwind = true,
        mode = "background",
      }
    }
  },
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      theme = 'hyper',
      config = {
        week_header = { enable = true },
        packages = { enable = true }, -- show how many plugins neovim loaded
        project = { enable = false, limit = 8, icon = 'your icon', label = '', action = 'Telescope find_files cwd=' },
        mru = { limit = 10, label = 'Most Recent', cwd_only = false },
        shortcut = {
          {
            desc = ' Update',
            group = '@property',
            action = "Lazy update",
            key = 'u',
          },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Files',
            group = 'Label',
            action = "Telescope find_files cwd=",
            key = 'f',
          },
          {
            desc = ' dotfiles',
            group = 'Number',
            action = 'Telescope dotfiles',
            key = 'd',
          },
        },
      },
    }
  },
  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      local notify = require 'notify'
      notify.setup {
        render = "wrapped-compact",
        background_colour = '#191724',
        -- icons = {
        --   ERROR = '',
        --   WARN = '',
        --   INFO = '',
        --   DEBUG = '',
        --   TRACE = '✎',
        -- },
      }
      vim.notify = notify
    end,
  },
  {
    'folke/which-key.nvim',
    enabled = false,
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {}
  },
  {
    'tpope/vim-surround',
    enabled = false
  },
  { 'tpope/vim-repeat' },
}
