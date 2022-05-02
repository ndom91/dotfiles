return function(on_attach)
  return {
    -- init_options = require("nvim-lsp-ts-utils").init_options,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- tsserver, stop messing with prettier da fuck!
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  }
end
