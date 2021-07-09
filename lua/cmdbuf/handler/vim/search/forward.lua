local historylib = require("cmdbuf.lib.history")
local messagelib = require("cmdbuf.lib.message")

local M = {}

M.flags = ""
M.searchforward = 1

function M.histories()
  return historylib.filter_map("search", function(cmd)
    if cmd == "" then
      return nil
    end
    return cmd
  end)
end

function M.add_history(_, line)
  vim.fn.histadd("search", line)
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    historylib.delete("search", line)
  end
end

function M.execute(self, line)
  vim.fn.setreg("/", line)
  vim.cmd("let &hlsearch = &hlsearch")
  vim.cmd("let v:searchforward = " .. self.searchforward)
  local ok, result = pcall(vim.fn.search, line, self.flags)
  if not ok then
    return messagelib.user_vim_error(result)
  end
  if result == 0 then
    return messagelib.user_error("E486: Pattern not found: " .. line)
  end
end

M.filetype = ""

return M
