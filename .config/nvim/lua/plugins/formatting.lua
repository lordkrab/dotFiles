return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        objc = { lsp_format = "never" },
        objcpp = { lsp_format = "never" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
      },
    },
  },
}
