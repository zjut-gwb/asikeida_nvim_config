if not vim.g.neovide then return end

vim.g.neovide_padding_top = 10
vim.g.neovide_padding_right = 0

vim.g.neovide_opacity = 0.90
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_input_ime = true
vim.g.neovide_underline_stroke_scale = 1.0

vim.g.neovide_cursor_unfocused_outline_width = 0
vim.g.neovide_cursor_unfocuesd_outline_width = 0
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_cursor_smooth_blink = true

vim.g.neovide_scale_factor = vim.g.neovide_scale_factor or 1.0

local function change_scale(delta) vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta end

vim.keymap.set({ "n", "i", "t" }, "<C-+>", function() change_scale(0.1) end, { desc = "Neovide Zoom In" })
vim.keymap.set({ "n", "i", "t" }, "<C-_>", function() change_scale(-0.1) end, { desc = "Neovide Zoom Out" })

vim.g.neovide_input_ime = false
vim.api.nvim_create_autocmd({
  "InsertEnter",
  "InsertLeave",
  "TermEnter",
  "TermLeave",
  "CmdlineEnter",
  "CmdlineLeave",
}, {
  group = vim.api.nvim_create_augroup("ime_input", { clear = true }),
  pattern = "*",
  callback = function(args) vim.g.neovide_input_ime = not not args.event:match "Enter$" end,
})
