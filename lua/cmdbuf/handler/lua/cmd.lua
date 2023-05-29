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

function M.histories(_, n)
  return historylib.filter_map("cmd", function(cmd)
    do
      local s, e = cmd:find("^%s*lua%s+")
      if s then
        return cmd:sub(e + 1)
      end
    end
    do
      local s, e = cmd:find("^%s*lua%=")
      if s then
        return cmd:sub(e)
      end
    end
    return nil
  end, n)
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
