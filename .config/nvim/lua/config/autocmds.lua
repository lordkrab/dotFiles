local group = vim.api.nvim_create_augroup("jakobberg_nvim", { clear = true })

vim.filetype.add({
  extension = {
    h = "objc",
    m = "objc",
    mm = "objcpp",
  },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = group,
  command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local telescope = require("telescope.builtin")
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", telescope.lsp_definitions, "Go to definition")
    map("gr", telescope.lsp_references, "Go to references")
    map("gi", telescope.lsp_implementations, "Go to implementation")
    map("K", vim.lsp.buf.hover, "Hover")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
    map("<leader>ds", telescope.lsp_document_symbols, "Document symbols")
    map("<leader>ld", vim.lsp.buf.definition, "Go to definition (native)")
    map("<leader>lr", vim.lsp.buf.references, "Go to references (native)")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ws", telescope.lsp_dynamic_workspace_symbols, "Workspace symbols")
  end,
})
