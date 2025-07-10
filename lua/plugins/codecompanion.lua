return {
  "franco-ruggeri/codecompanion-spinner.nvim",
  dependencies = {
    {
      "olimorris/codecompanion.nvim",
      config = true,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        {
          "saghen/blink.cmp",
          opts = {
            sources = {
              per_filetype = {
                codecompanion = { "codecompanion" },
              },
            },
          },
        },
      },
    },
  },
  opts = {},
}
