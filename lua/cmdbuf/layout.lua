local M = {}

--- @param width integer?
function M.vsplit_layout(width)
  return function()
    vim.cmd.vsplit()
    vim.cmd.wincmd("l")
    if width ~= nil then
      vim.api.nvim_win_set_width(0, width)
    end
  end
end

--- @param height integer?
function M.split_layout(height)
  return function()
    vim.cmd.split({ mods = { split = "botright" } })
    vim.cmd.wincmd("j")
    if height ~= nil then
      vim.api.nvim_win_set_height(0, height)
    end
  end
end

function M.tab_layout()
  return function()
    vim.cmd.tabedit()
  end
end

function M.open(f, reusable_window_ids, buffer_name)
  for _, window_id in ipairs(reusable_window_ids) do
    local bufnr = vim.api.nvim_win_get_buf(window_id)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == buffer_name then
      vim.api.nvim_set_current_win(window_id)
      return window_id
    end
  end

  f()

  return vim.api.nvim_get_current_win()
end

return M
