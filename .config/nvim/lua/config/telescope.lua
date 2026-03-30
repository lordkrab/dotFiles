local M = {}

local function format_path(path, cwd)
  if not path or path == "" then
    return ""
  end

  local root = vim.fs.normalize(cwd or vim.loop.cwd())
  local normalized = vim.fs.normalize(path)
  local prefix = root .. "/"

  if normalized == root then
    return vim.fs.basename(normalized)
  end

  if normalized:sub(1, #prefix) == prefix then
    return normalized:sub(#prefix + 1)
  end

  return vim.fn.fnamemodify(normalized, ":~")
end

local function lsp_references_entry_maker(opts)
  local make_entry = require("telescope.make_entry")
  local entry_maker = make_entry.gen_from_quickfix(vim.tbl_extend("force", opts or {}, {
    show_line = false,
  }))

  return function(entry)
    local item = entry_maker(entry)

    item.display = string.format("%s:%d", format_path(item.filename, opts.cwd), item.lnum)

    return item
  end
end

function M.lsp_references_paths(opts)
  opts = opts or {}
  opts.entry_maker = opts.entry_maker or lsp_references_entry_maker(opts)

  require("telescope.builtin").lsp_references(opts)
end

return M
