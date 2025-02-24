return -- lazy.nvim
{
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    ---@type table<string, snacks.win.Config>
    styles = {
      float = {
        position = "float",
        backdrop = 60,
        height = 0.9,
        width = 0.9,
        zindex = 50,
      },
      minimal = {
        wo = {
          cursorcolumn = false,
          cursorline = false,
          cursorlineopt = "both",
          colorcolumn = "",
          fillchars = "eob: ,lastline:…",
          list = false,
          listchars = "extends:…,tab:  ",
          number = false,
          relativenumber = false,
          signcolumn = "no",
          spell = false,
          winbar = "",
          statuscolumn = "",
          wrap = false,
          sidescrolloff = 0,
        },
      },
    },
    win = {
      -- your win configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}
