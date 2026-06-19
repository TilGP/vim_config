return {
  "mistweaverco/kulala.nvim",

  keys = {
    { "H", "<cmd>lua require('kulala.ui').show_headers()<cr>", desc = "kulala: Show Headers", ft = "kulala_ui" },
    { "B", "<cmd>lua require('kulala.ui').show_body()<cr>", desc = "kulala: Show Body", ft = "kulala_ui" },
    {
      "A",
      "<cmd>lua require('kulala.ui').show_headers_body()<cr>",
      desc = "kulala: Show Headers and Body",
      ft = "kulala_ui",
    },
    { "V", "<cmd>lua require('kulala.ui').show_verbose()<cr>", desc = "kulala: Show Verbose", ft = "kulala_ui" },
    {
      "O",
      "<cmd>lua require('kulala.ui').show_script_output()<cr>",
      desc = "kulala: Show Script Output",
      ft = "kulala_ui",
    },
    { "S", "<cmd>lua require('kulala.ui').show_stats()<cr>", desc = "kulala: Show Stats", ft = "kulala_ui" },
    { "R", "<cmd>lua require('kulala.ui').show_report()<cr>", desc = "kulala: Show Report", ft = "kulala_ui" },
    { "F", "<cmd>lua require('kulala.ui').toggle_filter()<cr>", desc = "kulala: Show Filter", ft = "kulala_ui" },
    {
      "<S-CR>",
      "<cmd>lua require('kulala.cmd.websocket').send()<cr>",
      desc = "kulala: Send WS Message",
      mode = { "n", "v" },
      ft = "kulala_ui",
    },
    {
      "<C-c>",
      "<cmd>lua require('kulala.cmd.websocket').close()<cr>",
      desc = "kulala: Close WS Connection",
      ft = "kulala_ui",
    },
    { "]", "<cmd>lua require('kulala.ui').show_next()<cr>", desc = "kulala: Next Response", ft = "kulala_ui" },
    { "[", "<cmd>lua require('kulala.ui').show_previous()<cr>", desc = "kulala: Previous Response", ft = "kulala_ui" },
    {
      "<CR>",
      "<cmd>lua require('kulala.ui').jump_to_response()<cr>",
      desc = "kulala: Jump to Response",
      ft = "kulala_ui",
    },
    {
      "X",
      "<cmd>lua require('kulala.ui').clear_responses_history()<cr>",
      desc = "kulala: Clear Responses History",
      ft = "kulala_ui",
    },
    { "?", "<cmd>lua require('kulala.ui').show_help()<cr>", desc = "kulala: Show Help", ft = "kulala_ui" },
    { "g?", "<cmd>lua require('kulala.ui').show_news()<cr>", desc = "kulala: Show News", ft = "kulala_ui" },
    {
      "|",
      "<cmd>lua require('kulala.ui').toggle_display_mode()<cr>",
      desc = "kulala: Toggle Split/Float",
      ft = "kulala_ui",
    },
    { "q", "<cmd>lua require('kulala.ui').close_kulala_buffer()<cr>", desc = "kulala: Close", ft = "kulala_ui" },
  },
  opts = {
    kulala_keymaps = false,
    ui = {
      max_response_size = 2 * 1024 * 1024, -- KiB
    },
    lsp = {
      formatter = false,
    },
    generate_bug_report = true,
  },
}
