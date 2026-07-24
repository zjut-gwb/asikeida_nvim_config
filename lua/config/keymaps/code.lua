return {
  { "<leader>yc", function() require("utils.plugin.code_context").copy_visual() end, mode = "v", desc = "Yank Code Context" },
  {
    "<leader>yC",
    function() require("utils.plugin.code_context").copy_visual { diagnostics = true } end,
    mode = "v",
    desc = "Yank Code Context with Diagnostics",
  },
}
