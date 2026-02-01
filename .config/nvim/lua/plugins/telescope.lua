return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>jw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
    { "<leader>r", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
    { "<leader>,", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
  },
  opts = function(_, opts)
    local previewers = require("telescope.previewers")

    -- Delta previewer for git status
    local delta_previewer = previewers.new_termopen_previewer({
      get_command = function(entry)
        return { "git", "diff", "HEAD", "--", entry.path }
      end,
    })

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      prompt_prefix = "❯ ",
      selection_caret = "❯ ",
      path_display = { "truncate" },
      mappings = {
        i = {
          ["<Esc>"] = "close",
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    })

    opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
      find_files = {
        no_ignore = false,
        hidden = true,
        follow = true,
      },
      git_status = {
        previewer = delta_previewer,
        mappings = {
          i = {
            ["<C-f>"] = "git_staging_toggle",
          },
        },
      },
    })

    return opts
  end,
}
