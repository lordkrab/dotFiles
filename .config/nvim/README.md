# Minimal Neovim Setup

This config keeps Neovim intentionally small:

- `lazy.nvim` for plugin management
- `mason.nvim` and `nvim-lspconfig` for LSPs
- `telescope.nvim` for navigation and search

After linking this config into `~/.config/nvim`, open Neovim and run:

```vim
:Lazy sync
:Mason
```

The default LSP list is in `lua/plugins.lua`:

- `lua_ls`
- `clangd`
- `gopls`
- `pyright`
- `ts_ls`

Trim that list if you want fewer servers.
