return {
  "okuuva/auto-save.nvim",
  version = "^1.0.0",
  opts = {
    trigger_events = { -- See :h events
      immediate_save = {
        { "BufLeave", pattern = { "*.html", "*.js", "*.css" } },
        { "FocusLost", pattern = { "*.html", "*.js", "*.css" } },
        { "QuitPre", pattern = { "*.html", "*.js", "*.css" } },
        { "VimSuspend", pattern = { "*.html", "*.js", "*.css" } },
        { "InsertLeave", pattern = { "*.html", "*.js", "*.css" } },
        { "TextChanged", pattern = { "*.html", "*.js", "*.css" } },
      },
      defer_save = {},
      cancel_deferred_save = {},
    },
  },
}
