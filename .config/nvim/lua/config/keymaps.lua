local map = vim.keymap.set

map("n", "gt", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "gT", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

map("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Go to below window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Go to above window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>ww", "<C-w>w", { desc = "Cycle to next window" })

map("n", "<C-j>", "<C-e>", { desc = "Scroll down one line" })
map("n", "<C-k>", "<C-y>", { desc = "Scroll up one line" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "n", "nzz", { desc = "Next search result (centered)" })
map("n", "N", "Nzz", { desc = "Previous search result (centered)" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
