return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {
      "NvimTreeFindFile",
      "NvimTreeFocus",
      "NvimTreeOpen",
      "NvimTreeToggle",
    },
    keys = {
      {
        "<leader>fe",
        "<cmd>NvimTreeToggle<cr>",
        desc = "Toggle file tree",
      },
      {
        "<leader>fE",
        "<cmd>NvimTreeFindFile<cr>",
        desc = "Reveal file in tree",
      },
    },
    config = function()
      require("nvim-tree").setup({
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        filters = {
          custom = {
            "%.g%.dart$",
            "%.freezed%.dart$",
          },
        },
        git = {
          ignore = false,
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          preserve_window_proportions = true,
          width = 34,
        },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "catppuccin/nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require("bufferline").setup({
        highlights = require("catppuccin.special.bufferline").get_theme(),
        options = {
          always_show_bufferline = true,
          diagnostics = "nvim_lsp",
          mode = "buffers",
          offsets = {
            {
              filetype = "lazy",
              text = "Lazy",
              text_align = "center",
            },
          },
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      preset = "modern",
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs = {
        add = { text = "|" },
        change = { text = "|" },
        delete = { text = "_" },
        topdelete = { text = "_" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next git hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous git hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
      end,
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local mason_servers = {
        clangd = {
          cmd = { "/Users/jakobberg/.swiftly/bin/clangd" },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                ST1020 = false,
              },
              buildFlags = { "-tags=integration" },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        pyright = {},
        ts_ls = {},
      }
      local system_servers = {
        dartls = {
          init_options = {
            closingLabels = true,
            flutterOutline = true,
            onlyAnalyzeProjectsWithOpenFiles = false,
            outline = true,
            suggestFromUnimportedLibraries = true,
          },
        },
      }

      require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = vim.tbl_keys(mason_servers),
      })

      for server, config in pairs(vim.tbl_extend("force", mason_servers, system_servers)) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local parser_install_dir = vim.fn.stdpath("data") .. "/site"
      vim.opt.runtimepath:append(parser_install_dir)

      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.schedule(function()
          vim.notify(
            "nvim-treesitter is installed on an incompatible branch. Run :Lazy sync to switch to master.",
            vim.log.levels.WARN
          )
        end)
        return
      end

      configs.setup({
        parser_install_dir = parser_install_dir,
        ensure_installed = {
          "bash",
          "dart",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        highlight = {
          additional_vim_regex_highlighting = false,
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({
            follow = true,
            hidden = true,
          })
        end,
        desc = "Find files",
      },
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({
            follow = true,
            hidden = true,
            no_ignore = true,
          })
        end,
        desc = "Find all files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--glob=!.g.dart", "--glob=!*.g.dart", "--glob=!*.freezed.dart" },
          })
        end,
        desc = "Live grep",
      },
      {
        "<leader>gd",
        function()
          require("telescope.builtin").git_status()
        end,
        desc = "Git diff files",
      },
      {
        "<leader>fG",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--no-ignore", "--glob=!.g.dart", "--glob=!*.g.dart", "--glob=!*.freezed.dart" },
          })
        end,
        desc = "Grep all files",
      },
      {
        "<leader>p",
        function()
          require("telescope.builtin").find_files({
            follow = true,
            hidden = true,
          })
        end,
        desc = "Find files",
      },
      {
        "<leader>P",
        function()
          require("telescope.builtin").find_files({
            follow = true,
            hidden = true,
            no_ignore = true,
          })
        end,
        desc = "Find all files",
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--glob=!.g.dart", "--glob=!*.g.dart", "--glob=!*.freezed.dart" },
          })
        end,
        desc = "Live grep",
      },
      {
        "<leader>?",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--no-ignore", "--glob=!.g.dart", "--glob=!*.g.dart", "--glob=!*.freezed.dart" },
          })
        end,
        desc = "Grep all files",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>,",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>r",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume picker",
      },
    },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "%.freezed%.dart$",
          "%.g%.dart$",
        },
        mappings = {
          i = {
            ["<C-h>"] = "which_key",
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Esc>"] = "close",
          },
        },
        path_display = { "truncate" },
        prompt_prefix = "> ",
        selection_caret = "> ",
      },
      pickers = {
        find_files = {
          follow = true,
          hidden = true,
        },
      },
      extensions = {
        fzf = {
          case_mode = "smart_case",
          fuzzy = true,
          override_file_sorter = true,
          override_generic_sorter = true,
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")

      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
