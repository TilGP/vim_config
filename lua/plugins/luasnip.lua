return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    { "benfowler/telescope-luasnip.nvim" },
    {
      "rafamadriz/friendly-snippets",
    },
  },
  config = function()
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
  end,
}
