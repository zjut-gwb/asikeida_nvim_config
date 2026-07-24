local function setup_lombok()
  local mason = vim.env.MASON or vim.fs.joinpath(vim.fn.stdpath "data", "mason")
  local lombok = vim.fs.joinpath(mason, "packages", "jdtls", "lombok.jar")
  if not vim.uv.fs_stat(lombok) then return end

  local args = vim.env.JDTLS_JVM_ARGS or ""
  if args:find("lombok", 1, true) then return end
  vim.env.JDTLS_JVM_ARGS = (args ~= "" and args .. " " or "") .. "-javaagent:" .. lombok
end

setup_lombok()

return {
  lsp = "jdtls",
  formatter = "google-java-format",
  pkgs = { "jdtls", "google-java-format" },
}
