return {
  "prosk-sudo/codewars.nvim",
  version = "*", -- pin to tagged releases; remove to track main
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim", -- kata picker / language picker
    -- optional
    "tadmccorkle/markdown.nvim", -- markdown rendering in description
  },
  opts = {},
}
