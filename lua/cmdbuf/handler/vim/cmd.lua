local M = {}

function M.histories()
  local count = vim.fn.histnr("cmd")
  local cmds = {}
  for i = 1, count, 1 do
    local cmd = vim.fn.histget("cmd", i)
    if cmd ~= "" then
      table.insert(cmds, cmd)
    end
  end
  return cmds
end

function M.add_history(_, line)
  vim.fn.histadd("cmd", line)
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    vim.fn.histdel("cmd", ("^%s$"):format(vim.fn.escape(line, "[]\\*")))
  end
end

function M.execute(_, line)
  local ok, result = pcall(vim.cmd, line)
  if not ok then
    local msg = result
    if vim.startswith(msg, "Vim(echoerr)") then
      msg = msg:sub(#("Vim:(echoerr)") + 1)
    elseif vim.startswith(msg, "Vim:") then
      msg = msg:sub(#("Vim:") + 1)
    end

    vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    vim.v.errmsg = msg
  end
end

M.filetype = "vim"

return M
