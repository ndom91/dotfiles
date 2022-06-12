return function(on_attach, capabilities)
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- jsonls, stop messing with prettier da fuck!
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
    -- settings = { json = { schemas = require("schemastore").json.schemas() } }
  }
end
