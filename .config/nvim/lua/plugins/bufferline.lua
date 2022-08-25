local present, bufferline = pcall(require, "bufferline")

if not present then
  vim.notify "Could not load bufferline"
  return
end

bufferline.setup {
  options = {
    indicator = { icon = "▎" },
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    right_mouse_command = "bdelete! %d",
    max_name_length = 25,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 25,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
    --   return "(" .. count .. ")"
    -- end,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,
    custom_areas = {
      right = function()
        local result = {}
        local seve = vim.diagnostic.severity
        local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
        local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
        local info = #vim.diagnostic.get(0, { severity = seve.INFO })
        local hint = #vim.diagnostic.get(0, { severity = seve.HINT })

        if error ~= 0 then
          result[1] = { text = "  " .. error, guifg = "#eb6f92" }
        end

        if warning ~= 0 then
          result[2] = { text = "  " .. warning, guifg = "#000000" } -- "#f6c177" }
        end

        if hint ~= 0 then
          result[3] = { text = "  " .. hint, guifg = "#9ccfd8" }
        end

        if info ~= 0 then
          result[4] = { text = "  " .. info, guifg = "#c4a7e7" }
        end
        return result
      end
    },
    offsets = {
      {
        filetype = "neo-tree",
        text = function()
          return vim.fn.getcwd()
        end,
        text_align = "center"
      },
      {
        filetype = "NvimTree",
        text = function()
          return vim.fn.getcwd()
        end,
        text_align = "center"
      }
    },
    color_icons = true,
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    separator_style = "thin",
    enforce_regular_tabs = true,
    always_show_bufferline = true
  }
}
