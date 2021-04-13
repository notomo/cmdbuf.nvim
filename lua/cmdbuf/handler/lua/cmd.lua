local M = {}

function M._lua(cmd)
  return "lua " .. cmd
end

function M.histories()
  local count = vim.fn.histnr("cmd")
  local cmds = {}
  for i = 1, count, 1 do
    local cmd = vim.fn.histget("cmd", i)
    local s, e = cmd:find("^%s*lua%s+")
    if s then
      table.insert(cmds, cmd:sub(e + 1))
    end
  end
  return cmds
end

function M.add_history(self, line)
  vim.fn.histadd("cmd", self._lua(line))
end

function M.delete_histories(self, lines)
  for _, line in ipairs(lines) do
    vim.fn.histdel("cmd", ("^%s$"):format(vim.fn.escape(self._lua(line), "[]\\*")))
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
