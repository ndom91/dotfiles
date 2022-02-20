require("rose-pine").setup(
  {
    ---@usage 'main'|'moon'
    dark_variant = "main",
    bold_vert_split = true,
    dim_nc_background = false,
    disable_background = false,
    disable_float_background = false,
    disable_italics = false,
    ---@usage string hex value or named color from rosepinetheme.com/palette
    groups = {
      border = "highlight_med",
      comment = "muted",
      link = "iris",
      punctuation = "subtle",
      error = "love",
      hint = "iris",
      info = "foam",
      warn = "gold",
      headings = {
        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam"
      },
      git_add = "pine",
      git_delete = "love",
      git_change = "rose",
      git_dirty = "rose",
      git_ignore = "muted",
      git_merge = "iris",
      git_rename = "pine",
      git_stage = "iris",
      git_text = "rose"
      -- or set all headings at once
      -- headings = 'subtle'
    }
  }
)

-- set colorscheme after options
vim.cmd("colorscheme rose-pine")

-- 	main = {
-- 		base = '#191724',
-- 		surface = '#1f1d2e',
-- 		overlay = '#26233a',
-- 		muted = '#6e6a86',
-- 		subtle = '#908caa',
-- 		text = '#e0def4',
-- 		love = '#eb6f92',
-- 		gold = '#f6c177',
-- 		rose = '#ebbcba',
-- 		pine = '#31748f',
-- 		foam = '#9ccfd8',
-- 		iris = '#c4a7e7',
-- 		highlight_low = '#21202e',
-- 		highlight_med = '#403d52',
-- 		highlight_high = '#524f67',
-- 		opacity = 0.1,
-- 		none = 'NONE',
-- 	},
