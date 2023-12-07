return {
  'nvim-tree/nvim-web-devicons',
  'nvim-lua/plenary.nvim',
  'nvim-lua/popup.nvim',
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_cursor {},

            -- pseudo code / specification for writing custom displays, like the one
            -- for "codeactions"
            -- specific_opts = {
            --   [kind] = {
            --     make_indexed = function(items) -> indexed_items, width,
            --     make_displayer = function(widths) -> displayer
            --     make_display = function(displayer) -> function(e)
            --     make_ordinal = function(e) -> string
            --   },
            --   -- for example to disable the custom builtin "codeactions" display
            --      do the following
            --   codeactions = false,
            -- }
          },
        },
      }
      require('telescope').load_extension 'ui-select'
    end,
  },
  { 'lvimuser/lsp-inlayhints.nvim', config = true },

  { 'tami5/lspsaga.nvim', enabled = false, config = true },

  -- icons on completion
  'onsails/lspkind-nvim',

  -- lsp function signature help on wildmenu
  {
    'ray-x/lsp_signature.nvim',
    config = function()
      local cfg = {
        -- hint_enable = false,
        -- transparency = 30,
        floating_window = false,
        bind = true,
        -- shadow_blend = 36,
        -- handler_opts = { border = "rounded" },
      }
      require('lsp_signature').setup(cfg)
    end,
  },
  -- floating status text in bottom right
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    event = 'LspAttach',
    config = function()
      require('fidget').setup {
        text = {
          spinner = 'dots',
        },
        window = {
          blend = 0,
        },
      }
    end,
  },
  {
    'folke/trouble.nvim',
    enabled = 'false',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = true,
  },
  -- ui elements
  {
    'MunifTanjim/nui.nvim',
    enabled = 'false',
  },

  -- tailwind token colorizer
  {
    'mrshmllow/document-color.nvim',
    enabled = false,
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

  -- "williamboman/mason.nvim",
  -- "williamboman/mason-lspconfig.nvim",
  -- "b0o/schemastore.nvim",
  -- "jose-elias-alvarez/null-ls.nvim",
  -- "hrsh7th/cmp-nvim-lua", -- Snippets
  -- 'jose-elias-alvarez/typescript.nvim',
  -- "folke/neodev.nvim", -- lua support for nvim config + development

  -- autocompletion
  -- cmp based copilot
  {
    'zbirenbaum/copilot.lua',
    -- event = { "VimEnter" },
    enabled = false,
    event = { 'BufRead' },
    dependencies = { 'zbirenbaum/copilot-cmp' },
    config = function()
      vim.defer_fn(function()
        require('copilot').setup {
          cmp = {
            enabled = true,
            method = 'getCompletionsCycling',
            ft_disable = {
              'markdown',
              'neo-tree',
              'terminal',
              'dashboard',
              'telescope.nvim',
              'terraform',
              'lsp-installer',
              'packer',
              'neo-tree-popup',
              'quickfix',
              'notify',
            },
          },
        }
      end, 100)
    end,
  },
  -- first-party github copilot plugin
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    enabled = false,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
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

      require('ibl').setup {
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
      }
    end,
  },
  {
    'RRethy/nvim-base16',
    enabled = 'false',
  },
  -- other themes
  -- "folke/tokyonight.nvim",
  -- "rmehri01/onenord.nvim",
  -- "wadackel/vim-dogrun",
  -- "challenger-deep-theme/vim",
  -- "EdenEast/nightfox.nvim",
  -- {
  -- 	"catppuccin/nvim",
  -- 	name = "catppuccin",
  -- 	enabled = false,
  -- 	config = function()
  -- 		require("catppuccin").setup({
  -- 			transparent_background = true,
  -- 			term_colors = true,
  -- 			integration = {
  -- 				nvimtree = {
  -- 					enabled = true,
  -- 					transparent_panel = true,
  -- 				},
  -- 				lsp_trouble = true,
  -- 			},
  -- 		})
  -- 		vim.cmd.colorscheme("catppuccin-mocha")
  -- 	end,
  -- },
  {
    'norcalli/nvim-colorizer.lua',
    -- colorize hex codes / color names
    config = function()
      require('colorizer').setup {
        '*',
        css = { rgb_fn = true },
        -- disabled in favor of document-color
        html = { names = false },
        '!dart',
      }
    end,
  },
  {
    'glepnir/dashboard-nvim',
    -- initial launch dashboard
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        theme = 'hyper',
        config = {
          week_header = { enable = true },
          shortcut = {
            {
              desc = ' Update',
              group = '@property',
              action = 'Lazy update',
              key = 'u',
            },
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              desc = ' Apps',
              group = 'DiagnosticHint',
              action = 'Telescope app',
              key = 'a',
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
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  -- notifications
  {
    'rcarriga/nvim-notify',
    -- name = "notify",
    lazy = false,
    config = function()
      local notify = require 'notify'
      notify.setup {
        -- render = "minimal",
        stages = 'fade_in_slide_out',
        background_colour = '#191724',
        icons = {
          ERROR = '',
          WARN = '',
          INFO = '',
          DEBUG = '',
          TRACE = '✎',
        },
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
  }, -- tpope plugins
  { 'tpope/vim-surround' }, -- Change surrounding arks
  { 'tpope/vim-repeat' }, -- extends . repeat
}
