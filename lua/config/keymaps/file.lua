local config = vim.fn.stdpath "config"
local dotfile = vim.env.XDG_CONFIG_HOME or "~/.config"

local fn = require "utils.keymaps"
local pick, file, cmd, plug = fn.pick, fn.file, fn.cmd, fn.config

local function get_reveal_target()
  if vim.bo.filetype == "oil" then
    local oil = require "oil"
    local dir = oil.get_current_dir(0)
    local entry = oil.get_cursor_entry()
    if not dir then return end
    return entry and (dir .. entry.name) or dir, entry ~= nil
  end

  local path = vim.api.nvim_buf_get_name(0)
  return path ~= "" and path or vim.fn.getcwd(), path ~= ""
end

local function reveal_current_file()
  local target, select = get_reveal_target()
  if not target then return end
  local args = select and { "dolphin", "--select", target } or { "dolphin", target }
  local job = vim.fn.jobstart(args, { detach = true })
  if job <= 0 then vim.notify("Failed to open Dolphin", vim.log.levels.ERROR) end
end

return {
  { "<C-e>", reveal_current_file, desc = "Reveal File" },
  { "<leader>fn", cmd "enew", desc = "New File" },
  { "<leader>fb", pick "buffers", desc = "Buffers" },
  { "<leader>ff", pick "files", desc = "Files" },
  { "<leader>fc", file(config), desc = "Config" },
  { "<leader>f.", file(dotfile), desc = "Dotfile" },
  { "<leader>fg", pick "git_files", desc = "Git" },
  { "<leader>fr", pick "recent", desc = "Recent" },
  { "<leader>fp", pick "projects", desc = "Projects" },
  { "<leader>fz", pick "zoxide", desc = "Zoxide" },
  { "<leader><space>", pick "smart", desc = "Files" },
  { "<leader>fs", plug "SratchOpen", desc = "Toggle Scratch Buffer" },
  { "<leader>fS", plug "SratchSelect", desc = "Select Scratch Buffer" },
}
