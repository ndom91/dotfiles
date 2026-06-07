return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      provider = 'openai_compatible',
      n_completions = 1,          -- single completion to save local resources
      context_window = 4096,
      request_timeout = 4,        -- abandon slow requests; stale ghost text is worthless
      throttle = 1000,            -- min ms between requests (you're on a big local model)
      debounce = 400,             -- wait after typing stops before firing
      provider_options = {
        openai_compatible = {
          api_key = 'LLAMA_DASH_MINUTAE_KEY',       -- any non-empty env var name;
          name = 'llama.cpp',
          end_point = 'http://llama-dash.puff.lan/v1/chat/completions',
          model = 'qwen3.6-35b',
          optional = {
            max_tokens = 256,
            temperature = 0.2,        -- low temp = stable, predictable completions
            top_p = 0.9,
            top_k = 20,
            chat_template_kwargs = { enable_thinking = false },
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
        auto_trigger_ignore_ft = {
          'gitcommit',
          'gitrebase',
          'TelescopePrompt',
          'snacks_picker_input',
          'oil',
          'help',
        },
        keymap = {
          accept = '<Tab>',
          accept_line = '<A-a>',
          prev = '<A-[>',
          next = '<A-]>',
          dismiss = '<A-e>',
        },
      },
    }
  end,
}
