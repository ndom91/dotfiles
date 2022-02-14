require "format".setup {
  ["*"] = {
    {
      cmd = {
        "sed -i 's/[ \t]*$//'"
      }
    } -- remove trailing whitespace
  },
  vim = {
    {
      cmd = {
        "luafmt -w replace"
      },
      start_pattern = "^lua << EOF$",
      end_pattern = "^EOF$"
    }
  },
  vimwiki = {
    {
      cmd = {
        "prettier -w --parser babel"
      },
      start_pattern = "^{{{javascript$",
      end_pattern = "^}}}$"
    }
  },
  lua = {
    {
      cmd = {
        function(file)
          return string.format("luafmt -i 2 -l 120 -w replace %s", file)
        end
      }
    }
  },
  go = {
    {
      cmd = {
        "gofmt -w",
        "goimports -w"
      },
      tempfile_postfix = ".tmp"
    }
  },
  vue = {
    {
      {
        cmd = {
          -- "prettier -w",
          "eslint --fix"
        }
      }
    }
  },
  javascriptreact = {
    {
      cmd = {
        "prettier -w"
      }
    }
  },
  typescriptreact = {
    {
      cmd = {
        "prettier -w --parser typescript"
      }
    }
  },
  javascript = {
    {
      cmd = {
        -- "prettier -w",
        "./node_modules/.bin/eslint --fix"
      }
    }
  },
  typescript = {
    {
      cmd = {"prettier -w --parser typescript"}
    }
  },
  html = {
    {
      cmd = {"prettier -w --parser html"}
    }
  },
  markdown = {
    {
      cmd = {
        "prettier -w --parser markdown"
      }
    }
  },
  css = {
    {
      cmd = {"prettier -w --parser css"}
    }
  },
  scss = {
    {
      cmd = {"prettier -w --parser scss"}
    }
  },
  json = {
    {
      cmd = {"prettier -w --parser json"}
    }
  },
  toml = {
    {
      cmd = {"prettier -w --parser toml"}
    }
  },
  yaml = {
    {
      cmd = {"prettier -w --parser yaml"}
    }
  }
}
