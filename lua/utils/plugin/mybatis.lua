local M = {}

local statements = { select = true, insert = true, update = true, delete = true }
local exclude_dirs = { ".git", ".gradle", ".idea", "build", "node_modules", "out", "target" }

local function root() return require("utils.root").get() end

local function read(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and lines or {}
end

local function parse_statement(line)
  local tag, id = line:match('<%s*(%w+)[^>]-id%s*=%s*"([^"]+)"')
  if tag then return tag, id end
  return line:match("<%s*(%w+)[^>]-id%s*=%s*'([^']+)'")
end

local function excluded(path)
  for _, dir in ipairs(exclude_dirs) do
    if path:find("/" .. dir .. "/", 1, true) then return true end
  end
  return false
end

local function project_files(ext)
  local base = root()
  if vim.fn.executable "rg" == 1 then
    local cmd = { "rg", "--files", "-g", "*." .. ext }
    for _, dir in ipairs(exclude_dirs) do
      vim.list_extend(cmd, { "-g", "!" .. dir .. "/**" })
    end

    local result = vim.system(cmd, { cwd = base, text = true }):wait()
    if result.code == 0 then
      return vim
        .iter(vim.split(result.stdout, "\n", { trimempty = true }))
        :map(function(path) return vim.fs.joinpath(base, path) end)
        :totable()
    end
  end

  return vim
    .iter(vim.fs.find(function(name) return name:match("%." .. ext .. "$") ~= nil end, {
      path = base,
      type = "file",
      limit = math.huge,
    }))
    :filter(function(path) return not excluded(path) end)
    :totable()
end

local function select_match(matches)
  if #matches == 0 then
    vim.notify("No MyBatis target found", vim.log.levels.WARN)
  elseif #matches == 1 then
    vim.cmd.edit(matches[1].path)
    vim.api.nvim_win_set_cursor(0, { matches[1].lnum, matches[1].col or 0 })
  else
    vim.ui.select(matches, {
      prompt = "MyBatis target",
      format_item = function(item)
        return ("%s:%d"):format(vim.fn.fnamemodify(item.path, ":."), item.lnum)
      end,
    }, function(item)
      if not item then return end
      vim.cmd.edit(item.path)
      vim.api.nvim_win_set_cursor(0, { item.lnum, item.col or 0 })
    end)
  end
end

local function java_info(path)
  local package, class
  for _, line in ipairs(read(path)) do
    package = package or line:match("^%s*package%s+([%w_.]+)%s*;")
    class = class or line:match("%f[%w]interface%s+([%w_]+)") or line:match("%f[%w]class%s+([%w_]+)")
    if package and class then break end
  end
  return package, class
end

local function current_java_method()
  local word = vim.fn.expand "<cword>"
  if word ~= "" then return word end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  for lnum = row, math.max(row - 20, 1), -1 do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
    local method = line:match("[%w_<>,%[%] ?]+%s+([%w_]+)%s*%(")
    if method and not statements[method] then return method end
  end
end

local function xml_files() return project_files "xml" end

local function java_files(simple_name)
  return vim
    .iter(project_files "java")
    :filter(function(path) return vim.fn.fnamemodify(path, ":t") == simple_name .. ".java" end)
    :totable()
end

local function jump_java_to_xml()
  local path = vim.api.nvim_buf_get_name(0)
  local package, class = java_info(path)
  local method = current_java_method()
  if not class or not method then
    vim.notify("Could not detect Mapper class or method", vim.log.levels.WARN)
    return
  end

  local full_name = package and (package .. "." .. class) or class
  local matches = {}
  for _, xml in ipairs(xml_files()) do
    local lines = read(xml)
    local namespace_ok = false
    for _, line in ipairs(lines) do
      local namespace = line:match('namespace%s*=%s*"([^"]+)"') or line:match("namespace%s*=%s*'([^']+)'")
      if namespace == full_name or namespace and namespace:match("%." .. vim.pesc(class) .. "$") then
        namespace_ok = true
        break
      end
    end
    if namespace_ok then
      for lnum, line in ipairs(lines) do
        local tag, id = parse_statement(line)
        if tag and statements[tag] and id == method then
          matches[#matches + 1] = { path = xml, lnum = lnum, col = math.max((line:find(id, 1, true) or 1) - 1, 0) }
        end
      end
    end
  end
  select_match(matches)
end

local function xml_context()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local namespace
  for _, line in ipairs(lines) do
    namespace = line:match('namespace%s*=%s*"([^"]+)"') or line:match("namespace%s*=%s*'([^']+)'")
    if namespace then break end
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  for lnum = row, 1, -1 do
    local line = lines[lnum] or ""
    local tag, id = parse_statement(line)
    if tag and statements[tag] then return namespace, id end
  end
  return namespace
end

local function jump_xml_to_java()
  local namespace, method = xml_context()
  if not namespace or not method then
    vim.notify("Could not detect MyBatis namespace or statement id", vim.log.levels.WARN)
    return
  end

  local simple_name = namespace:match("([%w_]+)$")
  local matches = {}
  for _, java in ipairs(java_files(simple_name)) do
    for lnum, line in ipairs(read(java)) do
      local found = line:match("%f[%w_]" .. vim.pesc(method) .. "%s*%(")
      if found then
        matches[#matches + 1] = { path = java, lnum = lnum, col = math.max((line:find(method, 1, true) or 1) - 1, 0) }
      end
    end
  end
  select_match(matches)
end

function M.jump()
  if vim.bo.filetype == "java" then
    jump_java_to_xml()
  elseif vim.bo.filetype == "xml" then
    jump_xml_to_java()
  else
    vim.notify("MyBatis jump only supports Java and XML buffers", vim.log.levels.WARN)
  end
end

return M
