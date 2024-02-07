return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require "harpoon"
    local extensions = require "harpoon.extensions"

    harpoon:setup {}

    vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)

    harpoon:extend(extensions.builtins.navigate_with_number())
    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set(
          "n",
          "<M-v>",
          function() harpoon.ui:select_menu_item { vsplit = true } end,
          { buffer = cx.bufnr }
        )
      end,
    }
  end,
}
