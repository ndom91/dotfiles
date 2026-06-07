return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      provider = 'openai_compatible',
      n_completions = 1,          -- single completion to save local resources
      context_window = 2048,      -- start small, raise once you gauge throughput
      provider_options = {
        openai_compatible = {
          api_key = 'LLAMA_DASH_MINUTAE_KEY',       -- any non-empty env var name;
          name = 'llama.cpp',
          end_point = 'http://llama-dash.puff.lan/v1/chat/completions',
          model = 'qwen3.6-35b',
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
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
