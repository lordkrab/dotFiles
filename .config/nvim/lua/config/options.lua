local opt = vim.opt

vim.cmd("syntax enable")
opt.background = "dark"

opt.autoread = true
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.hidden = true
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.showtabline = 2
opt.shiftwidth = 2
opt.signcolumn = "yes"
opt.smartcase = true
opt.shortmess:remove("S")
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
  virtual_text = {
    severity = { min = vim.diagnostic.severity.HINT },
    source = "if_many",
    spacing = 2,
  },
})
