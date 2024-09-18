local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M._lua(cmd)
  return "lua " .. cmd
end

local parse = function(line)
  do
    local s, e = line:find("^%s*lua%s*=?")
    if s then
      return line:sub(e + 1)
    end
  end
  do
    local s, e = line:find("^%s*=")
    if s then
      return line:sub(e + 1)
    end
  end
  return nil
end

function M.parse(_, line)
  return parse(line) or line
end

function M.histories()
  return historylib.filter_map("cmd", function(cmd)
    return parse(cmd)
  end)
end

function M.cmdline(self, line)
  return {
    str = ":" .. self._lua(line),
    column = #"lua ",
  }
end

function M.add_history(self, line)
  vim.fn.histadd("cmd", self._lua(line))
end

local _delete_history = function(line)
  if historylib.delete("cmd", line, [[\s*lua\s*]]) then
    return
  end
  if historylib.delete("cmd", line, [[\s*lua\s*=]]) then
    return
  end
  if historylib.delete("cmd", line, [[\s*=\s*]]) then
    return
  end
end
function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    _delete_history(line)
  end
end

function M.execute(self, line)
  local ok, msg = pcall(function()
    vim.cmd(self._lua(line))
  end)
  if not ok then
    messagelib.user_vim_error(msg)
    return
  end
end

M.filetype = "lua"

return M
