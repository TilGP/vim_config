return {
  "Blackcyan30/nvim-doccomment-tags",
  config = function()
    require("nvim-doccomment-tags.doccomment-tags").setup({
      -- Your optional configurations here
      -- tags = { "@mycustomtag", "@othertag" },
      -- hl_group = "Comment", -- Use the Comment highlight group
    })
  end,
}
