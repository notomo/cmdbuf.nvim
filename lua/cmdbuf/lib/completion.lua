local M = {}

function M.get(pattern, typ)
  local tmp = vim.o.wildoptions
  vim.api.nvim_set_option_value("wildoptions", "fuzzy", { operation = "remove" })
  local restore = function()
    vim.o.wildoptions = tmp
  end

  local ok, result = pcall(vim.fn.getcompletion, pattern, typ)
  if not ok then
    restore()
    error(result)
  end

  restore()
  return result
end

return M
