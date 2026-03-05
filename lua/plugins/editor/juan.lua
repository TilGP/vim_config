return {
  "minigian/juan-logs.nvim",
  build = "cargo build --release",
  enabled = true,
  config = function()
    require("juanlog").setup({
      threshold_size = 1024 * 1024 * 300, -- 100MB
      mode = "dynamic",
      lazy = true, -- background indexing. prevents neovim from freezing on 50GB files
      patterns = { "*.log", "*.txt", "*.csv", "*.json", "*.xml" }, -- Use the plugin for these filetypes
      enable_custom_statuscol = true, -- fakes absolute line numbers
      syntax = false, -- set to true to enable native vim syntax (can be slow on huge files)
    })
  end,
}
