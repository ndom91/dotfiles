return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      provider = 'openai_compatible',
      n_completions = 1,
      context_window = 2048,      -- lowered: shrinks prefill, few-shots already eat ~700 tokens
      request_timeout = 12,       -- raised: observed latency was ~9.3s (5s prefill + gen)
      throttle = 1500,            -- spaced out a bit more for a slow local model
      debounce = 500,
      provider_options = {
        openai_compatible = {
          -- function form avoids a crash when nvim's process env lacks the
          -- var (e.g. GUI launch); local llama.cpp ignores the key value
          api_key = function()
            return vim.env.LLAMA_DASH_MINUTAE_KEY or 'sk-no-key-required'
          end,
          name = 'llama.cpp',
          end_point = 'http://llama-dash.puff.lan/v1/chat/completions',
          model = 'qwen3.6-35b',
          optional = {
            max_tokens = 256,
            temperature = 0.2,
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
          'term',
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
