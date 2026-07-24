local M = {}

local function relative_path(path)
  local root = require("utils.root").get()
  if path == "" then return "[No Name]" end

  path = vim.fs.normalize(path)
  root = vim.fs.normalize(root)
  if path:sub(1, #root) == root then
    return path:sub(#root + 2)
  end
  return path
end

local function visual_range()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

local function highlight_range(start_line, end_line)
  local ns = vim.api.nvim_create_namespace "code_context_yank"
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for lnum = start_line - 1, end_line - 1 do
    vim.api.nvim_buf_add_highlight(bufnr, ns, "IncSearch", lnum, 0, -1)
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) end
  end, 150)
end

local function diagnostic_lines(start_line, end_line)
  local severity_name = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
  }
  local result = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
    local lnum = diagnostic.lnum + 1
    if severity_name[diagnostic.severity] and lnum >= start_line and lnum <= end_line then
      local col = diagnostic.col + 1
      local source = diagnostic.source and (diagnostic.source .. " ") or ""
      local code = diagnostic.code and (" [" .. diagnostic.code .. "]") or ""
      result[#result + 1] = ("- %s L%d:C%d %s%s%s"):format(
        severity_name[diagnostic.severity],
        lnum,
        col,
        source,
        diagnostic.message:gsub("\n", " "),
        code
      )
    end
  end
  return result
end

function M.copy_visual(opts)
  opts = opts or {}
  local start_line, end_line = visual_range()
  if start_line == 0 or end_line == 0 then
    vim.notify("No visual selection found", vim.log.levels.WARN)
    return
  end

  local path = relative_path(vim.api.nvim_buf_get_name(0))
  local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local parts = {
    ("文件: `%s`"):format(path),
    ("范围: `%d-%d`"):format(start_line, end_line),
    ("类型: `%s`"):format(filetype),
    "",
  }

  if opts.diagnostics then
    local diagnostics = diagnostic_lines(start_line, end_line)
    if #diagnostics > 0 then
      parts[#parts + 1] = "诊断:"
      vim.list_extend(parts, diagnostics)
      parts[#parts + 1] = ""
    end
  end

  vim.list_extend(parts, {
    ("```%s"):format(filetype),
    table.concat(lines, "\n"),
    "```",
  })

  local content = table.concat(parts, "\n")

  vim.fn.setreg("+", content)
  highlight_range(start_line, end_line)
  vim.notify(("Copied code context: %s:%d-%d"):format(path, start_line, end_line))
end

return M
