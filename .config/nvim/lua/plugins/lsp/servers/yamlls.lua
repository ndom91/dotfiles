return function(capabilities)
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return { settings = { yaml = {} } }
end
