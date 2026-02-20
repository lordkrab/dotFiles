return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")
      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>hd", gs.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "Diff this ~")
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame")
      map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted")

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")

      -- Telescope hunk list
      local function hunk_telescope_opts()
        return {
          previewer = require("telescope.previewers").new_termopen_previewer({
            get_command = function(entry)
              return { "git", "diff", "HEAD", "--", entry.filename }
            end,
          }),
          entry_maker = function(qf_entry)
            local filename = qf_entry.filename
            if not filename and qf_entry.bufnr and qf_entry.bufnr > 0 then
              filename = vim.api.nvim_buf_get_name(qf_entry.bufnr)
            end
            local short = vim.fn.fnamemodify(filename, ":~:.")
            local display_str = string.format("%s:%d", short, qf_entry.lnum)
            return {
              value = qf_entry,
              ordinal = display_str,
              display = display_str,
              filename = filename,
              lnum = qf_entry.lnum,
              col = qf_entry.col or 1,
            }
          end,
        }
      end

      map("n", "<leader>.", function()
        gs.setqflist()
        vim.schedule(function()
          vim.cmd("cclose")
          require("telescope.builtin").quickfix(hunk_telescope_opts())
        end)
      end, "List hunks")

      map("n", "<leader>>", function()
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "qf",
          once = true,
          callback = function()
            vim.schedule(function()
              vim.cmd("cclose")
              require("telescope.builtin").quickfix(hunk_telescope_opts())
            end)
          end,
        })
        gs.setqflist("all")
      end, "List all hunks")
    end,
  },
}
