local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}
M.__index = M

function M.new()
  local bufnr = vim.api.nvim_get_current_buf()
  return setmetatable({ _bufnr = bufnr }, M)
end

function M._lua(cmd)
  return "lua vim.b." .. cmd
end

function M.histories(self)
  if not vim.api.nvim_buf_is_valid(self._bufnr) then
    return {}
  end

  local cmds = historylib.filter_map("cmd", function(cmd)
    local s, e = cmd:find("^%s*lua%s+vim%.b%.")
    if not s then
      return nil
    end
    local line = cmd:sub(e + 1)
    local splitted = vim.split(line, "%s*=%s*", false)
    if #splitted < 2 then
      return nil
    end
    return line
  end)

  local prefix_length = #"b:" + 1
  local keys = vim.api.nvim_buf_call(self._bufnr, function()
    return vim.fn.getcompletion("b:*", "var")
  end)
  local vars = vim
    .iter(keys)
    :map(function(key)
      local name = key:sub(prefix_length)
      local value = vim.api.nvim_buf_get_var(self._bufnr, name)
      return ("%s = %s"):format(name, vim.inspect(value, { newline = " ", indent = " " }))
    end)
    :totable()

  local histories = {}
  table.insert(histories, "-- Buffer variables")
  vim.list_extend(histories, vars)
  table.insert(histories, "-- Buffer variable set commands")
  vim.list_extend(histories, cmds)
  return histories
end

function M.add_history(self, line)
  vim.fn.histadd("cmd", self._lua(line))
end

function M.delete_histories(self, lines)
  for _, line in ipairs(lines) do
    historylib.delete("cmd", self._lua(line))
  end
end

function M.execute(self, line)
  local ok, msg = pcall(vim.cmd, self._lua(line))
  if not ok then
    messagelib.user_vim_error(msg)
    return
  end
end

M.filetype = "lua"

return M
