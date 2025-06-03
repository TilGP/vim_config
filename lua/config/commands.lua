vim.api.nvim_create_user_command("CCChangeFileType", function()
  require("lib").change_filetype_window()
end, {})

-- clear all registers. Useful to reduce memory-usage after pasting a lot of long content
vim.api.nvim_create_user_command("WipeReg", function()
  for i = 34, 122 do
    pcall(vim.fn.setreg, string.char(i), {})
  end
end, {})

-- because I'm dumb and keep typing :Qa instead of :qa :)
vim.cmd("command! Qa qa")
