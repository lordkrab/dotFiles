local M = {}

local function lsp_references_entry_maker(opts)
  local entry_display = require("telescope.pickers.entry_display")
  local make_entry = require("telescope.make_entry")
  local utils = require("telescope.utils")
  local entry_maker = make_entry.gen_from_quickfix(vim.tbl_extend("force", {
    trim_text = true,
  }, opts or {}))

  local displayer = entry_display.create({
    separator = "  ",
    items = {
      {},
      { remaining = true },
    },
  })

  local function make_display(entry)
    local text = entry.text or ""
    text = text:gsub("^%s*(.-)%s*$", "%1")
    text = text:gsub(".* | ", "")

    return displayer({
      { string.format("%s:%d:%d", utils.transform_path(opts, entry.filename), entry.lnum, entry.col), "TelescopeResultsIdentifier" },
      text,
    })
  end

  return function(entry)
    local item = entry_maker(entry)
    item.display = make_display
    return item
  end
end

function M.lsp_references_paths(opts)
  opts = opts or {}
  opts.entry_maker = opts.entry_maker or lsp_references_entry_maker(opts)

  require("telescope.builtin").lsp_references(opts)
end

return M
