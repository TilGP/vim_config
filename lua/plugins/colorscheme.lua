return {
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = false,
    priority = 100,
    config = function()
      vim.g.nightflyTerminalColors = false
      vim.g.nightflyVirtualTextColor = true
      vim.g.nightflyWinSeparator = 2
      vim.g.nightflyTransparent = true
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfly",
    },
  },
}
