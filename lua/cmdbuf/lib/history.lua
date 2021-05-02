local M = {}

function M.delete(name, str)
  local pattern = ("^%s$"):format(vim.fn.escape(str, "[]\\*~"))
  vim.fn.histdel(name, pattern)
end

return M
