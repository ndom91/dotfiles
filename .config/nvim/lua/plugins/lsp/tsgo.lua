return function(dispatchers, config)
  local candidates = { "tsgo", "tsc" }

  if config.root_dir then
    table.insert(candidates, 1, vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsc"))
    table.insert(candidates, 1, vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsgo"))
  end

  local start = function(command)
    return vim.lsp.rpc.start({ command, "--lsp", "--stdio" }, dispatchers, {
      cwd = config.cmd_cwd,
      detached = config.detached,
      env = config.cmd_env,
    })
  end

  for _, command in ipairs(candidates) do
    if vim.fn.executable(command) == 1 then
      if vim.fs.basename(command) == "tsgo" then return start(command) end

      local version = vim.fn.system({ command, "--version" })
      local major_version = tonumber(version:match("(%d+)%.%d+"))
      if vim.v.shell_error == 0 and major_version and major_version >= 7 then return start(command) end
    end
  end

  error("No TypeScript 7+ tsc or transitional tsgo executable found")
end
