-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Maps a key or command to a mode.
--
-- @param mode The Vim mode (e.g. "n", "v", etc.)
-- @param lhs The left-hand side of the mapping (e.g. "j" for the 'j' key)
-- @param rhs The right-hand side of the mapping (e.g. a function or command to be executed)
-- @param opts Optional additional options to pass to the `vim.api.nvim_set_keymap` function
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require("which-key").add({
  {
    "<leader>i",
    function()
      require("lib").print_file_info()
    end,
    icon = "i",
    desc = "show information about the current cursor position",
  },
})
