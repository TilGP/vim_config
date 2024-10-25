vim.api.nvim_create_user_command("CCChangeFileType", function()
  require("lib").change_filetype_window()
end, {})

-- because I'm dumb and keep typing :Qa instead of :qa :)
vim.cmd("command! Qa qa")
