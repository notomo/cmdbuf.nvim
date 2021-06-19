local historylib = require("cmdbuf.lib.history")

local M = {}

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
  local ok, result = pcall(vim.cmd, self._lua(line))
  if not ok then
    local msg = result
    if vim.startswith(msg, "Vim(lua):") then
      msg = msg:sub(#("Vim(lua):") + 1)
    end

    vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    vim.v.errmsg = msg
  end
end

M.filetype = "lua"

return M
