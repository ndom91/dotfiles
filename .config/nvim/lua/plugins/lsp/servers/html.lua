return function(on_attach)
  return {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- html, stop messing with prettier da fuck!
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  }
end
