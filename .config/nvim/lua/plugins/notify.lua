local present, notify = pcall(require, "notify")

if not present then
  vim.notify "Could not load notify"
  return
end

local M = {}

function M.setup()
  notify.setup {
    render = 'compact',
    stages = 'fade_in_slide_out',
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "✎"
    }
  }
  vim.notify = notify
end

return M
