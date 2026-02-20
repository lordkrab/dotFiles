return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-frecency.nvim" },
    },
    config = function(_, opts)
        local previewers = require("telescope.previewers")
        local delta_previewer = previewers.new_termopen_previewer({
            get_command = function(entry)
                return { "git", "diff", "HEAD", "--", entry.path }
            end,
        })
        opts.pickers.git_status = {
            previewer = delta_previewer,
            mappings = {
                i = {
                    ["<C-f>"] = "git_staging_toggle",
                },
            },
        }
        require("telescope").setup(opts)
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("frecency")
    end,
    cmd = "Telescope", -- lazy-load when command is used
    keys = {
        { "<leader>p", "<cmd>Telescope frecency workspace=CWD<cr>", desc = "Find files (frecency)" },
        {
            "<leader>P",
            function()
                require("telescope.builtin").find_files({ no_ignore = true, file_ignore_patterns = {} })
            end,
            desc = "Find all files",
        },
        { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        {
            "<leader>?",
            function()
                require("telescope.builtin").live_grep({
                    additional_args = { "--no-ignore" },
                    file_ignore_patterns = {},
                })
            end,
            desc = "Grep all files",
        },
        { "<leader>jw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
        { "<leader>r", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
        { "<leader>,", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    },
    opts = {
        defaults = {
            attach_mappings = function()
                local actions = require("telescope.actions")
                actions.select_default:enhance({
                    post = function()
                        vim.cmd("normal! zz")
                    end,
                })
                return true
            end,
            prompt_prefix = "❯ ",
            selection_caret = "❯ ",
            path_display = { "truncate" },
            file_ignore_patterns = {
                "__pycache__",
                "%.freezed%.dart$",
                "%.g%.dart$",
                "vendor/",
                "api_client/",
                "tilled/client/",
                "backend/docs/",
                "backend/postman/",
            },

            mappings = {
                i = {
                    ["<Esc>"] = "close",
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                    ["<C-h>"] = function(...) return require("telescope.actions.layout").toggle_preview(...) end,
                },
            },
        },
        pickers = {
            find_files = {
                no_ignore = false, -- respect .gitignore
                hidden = true,
                follow = true,
            },
        },
        extensions = {
            frecency = {
                matcher = "fuzzy",
            },
        },
    },
}
