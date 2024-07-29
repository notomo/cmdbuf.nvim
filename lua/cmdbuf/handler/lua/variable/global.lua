local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M._lua(cmd)
  return "lua vim.g." .. cmd
end

local parse = function(cmd)
  local s, e = cmd:find("^%s*lua%s+vim%.g%.")
  if not s then
    return nil
  end
  local line = cmd:sub(e + 1)
  local splitted = vim.split(line, "%s*=%s*", false)
  if #splitted < 2 then
    return nil
  end
  return line
end

function M.parse(_, line)
  return parse(line) or line
end

function M.histories(_)
  local cmds = historylib.filter_map("cmd", function(cmd)
    return parse(cmd)
  end)

  local prefix_length = #"g:" + 1
  local keys = require("cmdbuf.lib.completion").get("g:*", "var")
  local vars = vim
    .iter(keys)
    :map(function(key)
      local name = key:sub(prefix_length)
      local value = vim.api.nvim_get_var(name)
      return ("%s = %s"):format(name, vim.inspect(value, { newline = " ", indent = " " }))
    end)
    :totable()

  local histories = {}
  table.insert(histories, "-- Global variables")
  vim.list_extend(histories, vars)
  table.insert(histories, "-- Global variable set commands")
  vim.list_extend(histories, cmds)
  return histories
end

function M.cmdline(self, line)
  return {
    str = ":" .. self._lua(line),
    column = #"lua vim.g.",
  }
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
