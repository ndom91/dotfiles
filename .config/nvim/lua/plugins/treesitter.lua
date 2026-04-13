return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  version = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()
  end,
  dependencies = {
    "IndianBoy42/tree-sitter-just", -- Just file syntax highlighting
    "windwp/nvim-ts-autotag", -- Treesitter autoclose and autorename HTML tags
    {
      "folke/ts-comments.nvim",
      opts = {},
      event = "VeryLazy",
      enabled = true,
    },
    {
      "nvim-treesitter/nvim-treesitter-context", -- Show scope context when scrolling
      opts = {
        max_lines = 4,
        on_attach = nil,
      },
    },
    { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },
  },
  opts = {},
}
