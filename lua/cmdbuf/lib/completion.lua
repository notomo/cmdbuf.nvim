local M = {}

function M.get(pattern, typ)
  local tmp = vim.opt.wildoptions
  vim.opt.wildoptions:remove("fuzzy")
  local restore = function()
    vim.opt.wildoptions = tmp
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
