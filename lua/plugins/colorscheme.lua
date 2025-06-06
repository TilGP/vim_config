return {
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nightflyTerminalColors = false
      vim.g.nightflyVirtualTextColor = true
      vim.g.nightflyWinSeparator = 2
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfly",
    },
  },
  { -- much bettter than the transparent feature of most colorschemes
    "xiyaowong/transparent.nvim",
    opts = {
      -- table: additional groups that should be cleared
      extra_groups = {},
      -- table: groups you don't want to clear
      exclude_groups = { "SnacksBackdrop", "CursorLine", "NeoTreeExpander" },
      -- function: code to be executed after highlight groups are cleared
      -- Also the user event "TransparentClear" will be triggered
      on_clear = function() end,
    },
  },
}
