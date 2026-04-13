return {
  "dmtrKovalenko/fff.nvim",
  init = function()
    vim.g.fff = vim.tbl_deep_extend("force", vim.g.fff or {}, {
      lazy_sync = true,
    })

    -- HACK: Neovim treesitter crashes on markdown nodes with `node:range()` returning nil,
    -- killing the highlighter decoration provider in fff preview buffers.
    -- Likely caused by stale treesitter queries on nvim 0.13 nightly.
    -- Track: https://github.com/neovim/neovim/issues/38303
    -- Remove this workaround once the error no longer reproduces.
    local _ts_start = vim.treesitter.start
    vim.treesitter.start = function(bufnr, lang, ...)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if (lang == "markdown" or lang == "markdown_inline") and vim.bo[bufnr].buftype == "nofile" then
        return
      end
      return _ts_start(bufnr, lang, ...)
    end
  end,
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    debug = {
      enabled = false,
      show_scores = true,
    },
    -- max_threads = 2,
    -- preview = {
    --   max_size = 2 * 1024 * 1024,
    --   chunk_size = 4096,
    --   binary_file_threshold = 2048,
    -- },
    -- grep = {
    --   max_file_size = 2 * 1024 * 1024,
    --   max_matches_per_file = 50,
    --   time_budget_ms = 100,
    -- },
    -- prompt = "λ ",
    prompt = " ",
    title = "Search",
    hl = {
      border = "EndOfBuffer",
      -- border = "NeoTreeTabSeparatorActive",
      -- border = "BlinkIndent",
    },
    git = {
      status_text_color = true,
    },
  },
  -- No need to lazy-load with lazy.nvim.
  -- This plugin initializes itself lazily.
  lazy = false,
  keys = {
    {
      "<leader>.",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "<leader>/",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "<leader>z",
      function()
        require("fff").live_grep({
          grep = {
            modes = { "fuzzy", "plain" },
          },
        })
      end,
      desc = "Live fffuzy grep",
    },
  },
}
