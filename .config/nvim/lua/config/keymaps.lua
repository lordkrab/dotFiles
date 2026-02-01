-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Navigate buffers with gt/gT (like vim tabs)
vim.keymap.set("n", "gt", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "gT", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Window navigation with <leader>w
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to below window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to above window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Cycle to next window" })
