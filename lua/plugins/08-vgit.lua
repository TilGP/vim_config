return {
  "tanvirtin/vgit.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    require("vgit").setup()
  end,
}
