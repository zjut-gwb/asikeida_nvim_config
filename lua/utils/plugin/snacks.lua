local terminal_cwds = {}

return {
  ---@param count integer
  ---@param cycle boolean?
  ---@return fun()
  word_goto = function(count, cycle)
    return function() Snacks.words.jump(count, cycle) end
  end,

  open_terminal = function()
    if vim.v.count ~= 0 then vim.t.snacks_recent_terminal = vim.v.count end
    local id = vim.t.snacks_recent_terminal or 1
    terminal_cwds[id] = terminal_cwds[id] or vim.fn.getcwd(0)
    local cwd = terminal_cwds[id]
    Snacks.terminal.toggle(nil, {
      count = id,
      cwd = cwd,
      win = {
        title = ("Terminal %d: %s"):format(id, vim.fn.fnamemodify(cwd, ":t")),
        title_pos = "right",
        wo = {
          winhighlight = "NormalFloat:Normal,FloatBorder:Normal",
        },
        relative = "editor",
        position = "float",
        width = 0.8,
        max_width = 130,
        height = 0.85,
        min_height = 20,
        backdrop = 100,
      },
    })
  end,

  hover_image = function()
    if Snacks.image.supports_terminal() then
      Snacks.image.hover()
    else
      Snacks.image.doc.at_cursor(vim.ui.open)
    end
  end,
}
