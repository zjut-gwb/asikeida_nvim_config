local function find_python(root_dir)
  for _, name in ipairs { ".venv", "venv" } do
    local python = vim.fs.joinpath(root_dir, name, "bin", "python")
    if vim.uv.fs_stat(python) then return python, name end
  end
end

return {
  lsp = {
    pyright = {
      before_init = function(_, config)
        local root_dir = config.root_dir or vim.uv.cwd()
        if not root_dir then return end

        local python, venv = find_python(root_dir)
        if not python then return end

        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          python = {
            pythonPath = python,
            venv = venv,
            venvPath = root_dir,
          },
        })
      end,
    },
  },
  formatter = "ruff_format",
  pkgs = { "pyright", "ruff" },
}
