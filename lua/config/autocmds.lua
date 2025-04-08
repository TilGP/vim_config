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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "kitty.conf",
  callback = function()
    require("which-key").add({
      {
        "<S-k>",
        function()
          local current_line = vim.fn.getline(".")
          local first_word = current_line:match("^%s*(%S+)")
          if first_word then
            local url = "https://sw.kovidgoyal.net/kitty/conf/#opt-kitty." .. first_word
            vim.fn.system({ "open", url }) -- Uses macOS 'open' command
          else
            print("No valid option found on the current line.")
          end
        end,
        icon = "i",
        desc = "show information about the current cursor position",
      },
    })
  end,
})
