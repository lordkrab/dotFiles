-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Navigate buffers with gt/gT (like vim tabs)
vim.keymap.set("n", "gt", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "gT", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
