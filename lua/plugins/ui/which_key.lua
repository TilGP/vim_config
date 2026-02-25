return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "classic",
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
  end,
}
