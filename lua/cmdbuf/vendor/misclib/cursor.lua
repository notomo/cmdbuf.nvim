local M = {}

--- @param window_id integer?
function M.to_bottom(window_id)
  window_id = window_id or 0
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(window_id, { count, 0 })
end

--- @param column integer
--- @param window_id integer?
function M.set_column(column, window_id)
  window_id = window_id or 0
  local row = vim.api.nvim_win_get_cursor(window_id)[1]

  local max_column = vim.api.nvim_win_call(window_id, function()
    return vim.fn.col("$")
  end)
  column = math.max(0, column)
  column = math.min(column, max_column)
  vim.api.nvim_win_set_cursor(window_id, { row, column })
end

--- @param position [integer,integer]
--- @param window_id integer?
function M.set(position, window_id)
  window_id = window_id or 0
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local count = vim.api.nvim_buf_line_count(bufnr)
  local row = count >= position[1] and position[1] or count
  vim.api.nvim_win_set_cursor(window_id, { row, position[2] })
end

return M
