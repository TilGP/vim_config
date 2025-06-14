vim.api.nvim_create_user_command("CCChangeFileType", function()
  require("lib").change_filetype_window()
end, {})

-- clear all registers. Useful to reduce memory-usage after pasting a lot of long content
vim.api.nvim_create_user_command("CCWipeReg", function()
  for i = 34, 122 do
    pcall(vim.fn.setreg, string.char(i), {})
  end
end, {})

-- remove all ANSi-Escape codes
vim.api.nvim_create_user_command("CCRemoveANSI", function()
  local pattern = "\27%[[0-9;]*[A-Za-z]" -- ANSI escape code regex pattern
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    lines[i] = line:gsub(pattern, "")
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end, { desc = "Remove ANSI escape codes from buffer" })

-- because I'm dumb and keep typing :Qa instead of :qa :)
vim.cmd("command! Qa qa")
