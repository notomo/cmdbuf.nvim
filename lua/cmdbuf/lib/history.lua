local M = {}

function M.delete(name, str)
  local pattern = ("^%s$"):format(vim.fn.escape(str, "[]\\*~"))
  vim.fn.histdel(name, pattern)
end

function M.filter_map(name, f, n)
  vim.validate({
    name = { name, "string" },
    f = { f, "function" },
    n = { n, function(x) return x == nil or type(x) == "number" end, "number or nil" },
  })
  local count = vim.fn.histnr(name)
  n = n or count
  local cmds = {}
  for i = count, 1, -1 do
    local history = vim.fn.histget(name, i)
    local cmd = f(history)
    if cmd then
      table.insert(cmds, 1, cmd)
    end
    if #cmds >= n then
      return cmds
    end
  end
  return cmds
end

return M
