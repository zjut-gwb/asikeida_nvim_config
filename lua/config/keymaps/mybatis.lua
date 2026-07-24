return {
  { "<leader>mj", function() require("utils.plugin.mybatis").jump() end, desc = "MyBatis Jump" },
  { "<leader>mJ", function() require("utils.plugin.mybatis").jump { command = "vsplit" } end, desc = "MyBatis Jump Vsplit" },
}
