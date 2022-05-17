local M = {}

function M.to_bottom(window_id)
  vim.validate({ window_id = { window_id, "number", true } })
  window_id = window_id or 0
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(window_id, { count, 0 })
end

function M.set_column(column, window_id)
  vim.validate({
    column = { column, "number" },
    window_id = { window_id, "number", true },
  })
  window_id = window_id or 0
  local row = vim.api.nvim_win_get_cursor(window_id)[1]
  vim.api.nvim_win_set_cursor(window_id, { row, column })
end

function M.set(position, window_id)
  vim.validate({
    column = { position, "table" },
    window_id = { window_id, "number", true },
  })
  window_id = window_id or 0
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local count = vim.api.nvim_buf_line_count(bufnr)
  local row = count >= position[1] and position[1] or count
  vim.api.nvim_win_set_cursor(window_id, { row, position[2] })
end

return M
