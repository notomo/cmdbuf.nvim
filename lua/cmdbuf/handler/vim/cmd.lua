local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M.parse(_, line)
  return line
end

function M.histories()
  return historylib.filter_map("cmd", function(cmd)
    if cmd == "" then
      return nil
    end
    return cmd
  end)
end

function M.cmdline(_, line)
  return {
    str = ":" .. line,
  }
end

function M.add_history(_, line)
  vim.fn.histadd("cmd", line)
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    historylib.delete("cmd", line)
  end
end

function M.execute(_, line)
  local ok, result = pcall(vim.cmd, line)
  if not ok then
    messagelib.user_vim_error(result)
    return
  end
end

M.filetype = "vim"

return M
