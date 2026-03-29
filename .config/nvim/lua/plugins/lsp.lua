return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        clangd = {
          cmd = { "/Users/jakobberg/.swiftly/bin/clangd" },
        },
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=integration" },
              analyses = {
                ST1020 = false,
              },
            },
          },
        },
      },
    },
  },
}
