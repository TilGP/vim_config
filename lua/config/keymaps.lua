-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap("n", "tn", ":Telescope notify<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<F8>", ":DapStepOver<CR>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<F7>", ":DapStepInto<CR>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<F6>", ":DapTerminate<CR>", { noremap = true, silent = false })

vim.keymap.set("n", "<C-+>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-->", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<A-+>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<A-->", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
