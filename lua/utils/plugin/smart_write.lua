local M = {}

local save_dir = vim.fs.normalize "/home/asikeida/Documents/nvim_documents"

local function is_unnamed() return vim.api.nvim_buf_get_name(0) == "" end

local function normalize_name(input)
  local name = vim.trim(input or ""):gsub("^/+", "")
  if name == "" then return end
  if not name:match("%.md$") then name = name .. ".md" end
  return name
end

local function save_as(name)
  local path = vim.fs.joinpath(save_dir, name)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":p:h"), "p")
  vim.api.nvim_buf_set_name(0, path)
  vim.cmd.write()
  if vim.bo.filetype == "" then vim.bo.filetype = "markdown" end
end

local function input_filename(opts)
  opts = opts or {}
  local input = Snacks and Snacks.input or vim.ui.input
  input({ prompt = "Save as: ", default = "untitled" }, function(value)
    local name = normalize_name(value)
    if not name then return end
    save_as(name)
    if opts.quit then vim.cmd.quit() end
  end)
end

function M.write()
  if is_unnamed() then
    input_filename()
  else
    vim.cmd.write()
  end
end

function M.write_quit()
  if is_unnamed() then
    input_filename { quit = true }
  else
    vim.cmd.write()
    vim.cmd.quit()
  end
end

function M.commandline_enter()
  local line = vim.trim(vim.fn.getcmdline())
  if vim.fn.getcmdtype() == ":" and is_unnamed() then
    if line == "w" or line == "write" then
      return vim.api.nvim_replace_termcodes("<C-u>SmartWrite<CR>", true, false, true)
    elseif line == "wq" or line == "wq!" or line == "writequit" or line == "writequit!" then
      return vim.api.nvim_replace_termcodes("<C-u>SmartWriteQuit<CR>", true, false, true)
    end
  end
  return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
end

function M.setup()
  vim.api.nvim_create_user_command("SmartWrite", M.write, { desc = "Write unnamed buffers into nvim_documents", force = true })
  vim.api.nvim_create_user_command(
    "SmartWriteQuit",
    M.write_quit,
    { desc = "Write unnamed buffers into nvim_documents and quit", force = true }
  )
end

return M
