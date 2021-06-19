local historylib = require("cmdbuf.lib.history")

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
  vim.cmd("let &hlsearch = 1")
  vim.cmd("let v:searchforward = " .. self.searchforward)
  local result = vim.fn.search(line, self.flags)
  if result == 0 then
    local msg = "E486: Pattern not found: " .. line
    vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    vim.v.errmsg = msg
  end
end

M.filetype = ""

return M
