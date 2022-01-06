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

function M.histories()
  return historylib.filter_map("cmd", function(cmd)
    local s, e = cmd:find("^%s*lua%s+")
    if not s then
      return nil
    end
    return cmd:sub(e + 1)
  end)
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
    return messagelib.user_vim_error(msg)
  end
end

M.filetype = "lua"

return M
