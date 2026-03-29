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
      local servers = {
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

      require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = vim.tbl_keys(servers),
      })

      for server, config in pairs(servers) do
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
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fG",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--no-ignore" },
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
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>?",
        function()
          require("telescope.builtin").live_grep({
            additional_args = { "--no-ignore" },
          })
        end,
        desc = "Grep all files",
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
