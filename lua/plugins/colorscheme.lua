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
      vim.g.nightflyTransparent = true
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
