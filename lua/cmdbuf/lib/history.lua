local M = {}

function M.delete(name, str, prefix)
  prefix = prefix or ""
  local pattern = ("^%s%s$"):format(prefix, vim.fn.escape(str, "[]\\*~"))
  local result = vim.fn.histdel(name, pattern)
  return result == 1
end

function M.filter_map(name, f)
  vim.validate({ name = { name, "string" }, f = { f, "function" } })
  local count = vim.fn.histnr(name)
  local cmds = {}
  for i = 1, count, 1 do
    local history = vim.fn.histget(name, i)
    local cmd = f(history)
    if cmd then
      table.insert(cmds, cmd)
    end
  end
  return cmds
end

return M
