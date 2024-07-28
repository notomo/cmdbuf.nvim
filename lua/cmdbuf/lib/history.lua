local M = {}

function M.delete(name, str, prefix)
  prefix = prefix or ""
  local pattern = ("^%s%s$"):format(prefix, vim.fn.escape(str, "[]\\*~"))
  local result = vim.fn.histdel(name, pattern)
  return result == 1
end

local range = function(s, e, step)
  local i = s
  return function()
    if i > e then
      return nil
    end
    local next = i
    i = next + step
    return next
  end
end

function M.filter_map(name, f)
  vim.validate({ name = { name, "string" }, f = { f, "function" } })
  local count = vim.fn.histnr(name)
  return vim
    .iter(range(1, count, 1))
    :map(function(i)
      local history = vim.fn.histget(name, i)
      return f(history)
    end)
    :totable()
end

return M
