local group = vim.api.nvim_create_augroup("jakobberg_nvim", { clear = true })

local function enable_lsp_completion(client, bufnr)
  if not client:supports_method("textDocument/completion") then
    return
  end

  local provider = client.server_capabilities.completionProvider or {}
  local triggers = provider.triggerCharacters or {}
  local seen = {}

  for _, char in ipairs(triggers) do
    seen[char] = true
  end

  for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
    if not seen[char] then
      table.insert(triggers, char)
      seen[char] = true
    end
  end

  provider.triggerCharacters = triggers
  client.server_capabilities.completionProvider = provider

  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.lsp.completion.enable(true, client.id, bufnr, {
    autotrigger = true,
  })

  vim.keymap.set("i", "<C-Space>", function()
    vim.lsp.completion.get()
  end, { buffer = bufnr, desc = "Trigger completion" })
end

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

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(event)
    local opt = vim.opt_local

    opt.conceallevel = 2
    opt.linebreak = true
    opt.spell = true
    opt.wrap = true

    vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", {
      buffer = event.buf,
      desc = "Toggle markdown render",
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local telescope = require("telescope.builtin")
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = desc })
    end

    if client then
      enable_lsp_completion(client, event.buf)
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
