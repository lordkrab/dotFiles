local opt = vim.opt

vim.cmd("syntax enable")
opt.background = "dark"

opt.autoread = true
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.ignorecase = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.updatetime = 250
opt.wrap = false

vim.diagnostic.config({
  float = { border = "rounded" },
  severity_sort = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  virtual_text = false,
})
