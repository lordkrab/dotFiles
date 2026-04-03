local group = vim.api.nvim_create_augroup("jakobberg_nvim", { clear = true })
local uv = vim.uv or vim.loop
local last_workspace_check = 0
local workspace_check_interval = 2000

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

local function is_reloadable_buffer(bufnr)
  return vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buflisted
    and vim.bo[bufnr].buftype == ""
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
    and not vim.bo[bufnr].modified
end

local function check_buffer(bufnr)
  if not is_reloadable_buffer(bufnr) then
    return
  end

  vim.cmd(("silent! checktime %d"):format(bufnr))
end

local function check_workspace_buffers(force)
  if vim.fn.mode() == "c" then
    return
  end

  local now = uv.now()
  if not force and now - last_workspace_check < workspace_check_interval then
    return
  end

  last_workspace_check = now

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    check_buffer(bufnr)
  end
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

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function(event)
    check_buffer(event.buf)
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function(event)
    check_workspace_buffers(event.event == "FocusGained")
  end,
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
    local telescope_config = require("config.telescope")
    local telescope = require("telescope.builtin")
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = desc })
    end

    if client then
      enable_lsp_completion(client, event.buf)
    end

    map("gd", telescope.lsp_definitions, "Go to definition")
    map("gr", telescope_config.lsp_references_paths, "Go to references")
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
