-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Associate "Jeninsfile" with groovy filetype
vim.cmd([[
  autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy
]])

-- Run :AnsiEsc on files with the .ansi ending
vim.cmd([[
  autocmd BufRead,BufNewFile *.ansi AnsiEsc
]])

-- associate *.ssv with filetzpe=csv_semicolon
vim.cmd([[
  autocmd BufNewFile,BufRead *.ssv set filetype=csv_semicolon
  ]])
