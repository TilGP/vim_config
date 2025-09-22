-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

if require("lib").is_ssh_session() then
  opt.clipboard = "unnamedplus"
end

opt.scrolloff = 10

opt.spelllang = { "de", "en" }

-- disable conceal
opt.conceallevel = 0

opt.shiftwidth = 4
opt.expandtab = true

opt.exrc = true

vim.g.mkdp_auto_close = 0
