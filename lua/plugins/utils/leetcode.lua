return {
  { "nvim-lua/plenary.nvim", load_before = { "leetcode.nvim", "opencode.nvim" } },
  { "MunifTanjim/nui.nvim", load_before = { "leetcode.nvim", "noice.nvim" } },
  {
    "3rd/image.nvim",
    load_before = "leetcode.nvim",
    opts = {
      processor = "magick_cli",
    },
  },
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    keys = {
      { "<leader>L", "<cmd>Leet<cr>", desc = "LeetCode" },
    },
    opts = {
      lang = "golang",
      cn = {
        enabled = true,
        translator = true,
        translate_problems = true,
      },
      plugins = {
        non_standalone = true,
      },
      picker = {
        provider = "snacks-picker",
      },
      image_support = true,
    },
    after = function(spec)
      require("leetcode").setup(spec.opts)

      pcall(require("lz.n").trigger_load, "nvim-treesitter")
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then return end

      local installed = {}
      for _, lang in ipairs(ts.get_installed()) do
        installed[lang] = true
      end
      if not installed.html then ts.install { "html" } end
    end,
  },
}
