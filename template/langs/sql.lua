---@type config.language.Config
return {
  treesitter = { "sql" },
  lsp = "postgres_lsp",
  formatter = "sqlfluff",
  packages = { "postgres-language-server", "sqlfluff", "tree-sitter-cli" },
  plugin = {
    {
      "tpope/vim-dadbod",
      cmd = "DB",
      load_before = { "vim-dadbod-ui", "vim-dadbod-completion" },
    },
    {
      "kristijanhusak/vim-dadbod-ui",
      cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
      before = function()
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_save_location = vim.fn.stdpath "data" .. "/db_ui"
      end,
    },
    {
      "kristijanhusak/vim-dadbod-completion",
      ft = "sql",
    },
  },
}
