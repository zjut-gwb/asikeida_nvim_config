return {
  {
    "nvim-lua/plenary.nvim",
    load_before = "neo-tree.nvim",
  },

  {
    "MunifTanjim/nui.nvim",
    load_before = "neo-tree.nvim",
  },

  {
    "nvim-neo-tree/neo-tree.nvim/v3.x",
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        function() vim.cmd "Neotree toggle reveal left" end,
        desc = "Explorer",
      },
    },
    before = function()
      vim.cmd.packadd "plenary.nvim"
      vim.cmd.packadd "nui.nvim"
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
            "node_modules",
          },
        },
      },
      window = {
        width = 34,
        mappings = {
          ["<space>"] = "none",
          ["<BS>"] = "navigate_up",
          ["."] = "toggle_hidden",
          ["o"] = "open",
          ["O"] = "system_open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["t"] = "open_tabnew",
        },
      },
    },
    after = function(spec) require("neo-tree").setup(spec.opts) end,
  },
}
