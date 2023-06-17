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
    do
      local s, e = cmd:find("^%s*lua%s*=?")
      if s then
        return cmd:sub(e + 1)
      end
    end
    do
      local s, e = cmd:find("^%s*=")
      if s then
        return cmd:sub(e + 1)
      end
    end
    return nil
  end)
end

function M.add_history(self, line)
  vim.fn.histadd("cmd", self._lua(line))
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    if historylib.delete("cmd", line, [[\s*lua\s*]]) then
      goto continue
    end
    if historylib.delete("cmd", line, [[\s*lua\s*=]]) then
      goto continue
    end
    if historylib.delete("cmd", line, [[\s*=\s*]]) then
      goto continue
    end
    ::continue::
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
