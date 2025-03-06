-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.filetype.add({
  pattern = {
    [".*.jenkinsfile"] = "groovy",
    ["Jenkinsfile..*"] = "groovy",
    ["Jenkinsfile"] = "groovy",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "groovy", "sh", "cmake", "dockerfile" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
  pattern = { "groovy", "*.jenkinsfile" },
  callback = function()
    require("jenkinsfile_linter").validate()
  end,
})
