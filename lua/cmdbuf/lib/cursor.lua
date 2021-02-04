local M = {}

function M.to_bottom(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(0, {count, 0})
end

function M.set_column(column)
  vim.validate({column = {column, "number"}})
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, {row, column - 1})
end

return M
