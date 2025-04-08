local SymbolKind = vim.lsp.protocol.SymbolKind

return {
  "Wansmer/symbol-usage.nvim",
  event = "BufReadPre", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
  config = function()
    require("symbol-usage").setup({
      filetypes = {},
      hl = { link = "Comment" },
      kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Operator },
      kinds_filter = {},
      vt_position = "above",
      vt_priority = nil,
      request_pending_text = "loading...",
      references = { enabled = true, include_declaration = false },
      definition = { enabled = false },
      implementation = { enabled = false },
      disable = { lsp = {}, filetypes = {}, cond = {} },
      symbol_request_pos = "end",
      log = {
        enabled = false,
        level = "INFO",
        notify = { enabled = false },
        stdout = { enabled = false },
        log_file = { enabled = false },
      },
    })
  end,
}
