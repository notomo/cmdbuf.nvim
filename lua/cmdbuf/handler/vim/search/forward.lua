local M = {}

M.flags = ""
M.searchforward = 1

function M.histories()
  local count = vim.fn.histnr("search")
  local cmds = {}
  for i = 1, count, 1 do
    local cmd = vim.fn.histget("search", i)
    if cmd ~= "" then
      table.insert(cmds, cmd)
    end
  end
  return cmds
end

function M.add_history(_, line)
  vim.fn.histadd("search", line)
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    vim.fn.histdel("search", ("^%s$"):format(vim.fn.escape(line, "[]\\*")))
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
