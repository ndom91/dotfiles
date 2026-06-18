local function git_lines(root, args)
  local full_args = { "git", "-C", root }
  vim.list_extend(full_args, args)

  local lines = vim.fn.systemlist(full_args)
  if vim.v.shell_error ~= 0 then return nil end
  return lines
end

local function first_git_line(root, args)
  local lines = git_lines(root, args)
  return lines and lines[1] or nil
end

local function git_root()
  return first_git_line(vim.uv.cwd(), { "rev-parse", "--show-toplevel" })
end

local function configured_pr_bases()
  local configured = vim.g.fff_pr_base
  if type(configured) == "string" and configured ~= "" then return { configured } end
  if type(configured) == "table" then return configured end

  local bases = {}
  local origin_head = first_git_line(vim.uv.cwd(), { "symbolic-ref", "refs/remotes/origin/HEAD", "--short" })
  if origin_head and origin_head ~= "" then table.insert(bases, origin_head) end

  vim.list_extend(bases, {
    "origin/main",
    "origin/master",
    "origin/trunk",
    "origin/develop",
    "main",
    "master",
    "trunk",
    "develop",
  })

  return bases
end

local function branch_changed_files()
  local root = git_root()
  if not root or root == "" then return nil end

  local seen = {}
  for _, base in ipairs(configured_pr_bases()) do
    if base and base ~= "" and not seen[base] then
      seen[base] = true

      local merge_base = first_git_line(root, { "merge-base", base, "HEAD" })
      if merge_base and merge_base ~= "" then
        local files = git_lines(root, { "diff", "--name-only", "--diff-filter=ACMR", merge_base .. "...HEAD" })
        if files and #files > 0 then
          local changed = { count = 0, base = base }
          for _, file in ipairs(files) do
            if file ~= "" then
              changed[file] = true
              changed.count = changed.count + 1
            end
          end
          return changed
        end
      end
    end
  end

  return nil
end

local function pr_changed_renderer(changed_files)
  local file_renderer = require("fff.picker_ui.file_renderer")

  return {
    render_line = file_renderer.render_line,
    apply_highlights = function(item, ctx, item_idx, buf, ns_id, line_idx, line_content)
      file_renderer.apply_highlights(item, ctx, item_idx, buf, ns_id, line_idx, line_content)

      if not changed_files[item.relative_path] then return end

      local git_hl = ctx.config.hl.git_modified or "FFFGitModified"
      vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
        sign_text = "P ",
        sign_hl_group = git_hl,
        priority = 1002,
      })

      local icons = require("fff.file_picker.icons")
      local icon = icons.get_icon(item.name, item.extension, false)
      local icon_width = icon and (vim.fn.strdisplaywidth(icon) + 1) or 0
      local filename = ctx.format_file_display(item, math.max(ctx.max_path_width - icon_width, 40))
      local filename_start = icon and (#icon + 1) or 0

      if #filename > 0 then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, filename_start, {
          end_col = filename_start + #filename,
          hl_group = git_hl,
          priority = 90,
        })
      end
    end,
  }
end

local function find_files_with_pr_highlights()
  local changed_files = branch_changed_files()
  if not changed_files then
    require("fff").find_files()
    return
  end

  require("fff").find_files({
    renderer = pr_changed_renderer(changed_files),
    title = string.format("Search (%d PR files vs %s)", changed_files.count, changed_files.base),
  })
end

return {
  "dmtrKovalenko/fff.nvim",
  init = function()
    vim.g.fff = vim.tbl_deep_extend("force", vim.g.fff or {}, {
      lazy_sync = true,
    })
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
        find_files_with_pr_highlights()
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
