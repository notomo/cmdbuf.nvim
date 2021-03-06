local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}

function M.histories()
  return historylib.filter_map("cmd", function(cmd)
    if cmd == "" then
      return nil
    end
    return cmd
  end)
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
    return messagelib.user_vim_error(result)
  end
end

M.filetype = "vim"

return M
