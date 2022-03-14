local M = {}

function M.user_error(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
  vim.v.errmsg = msg
end

function M.user_vim_error(msg)
  vim.validate({ msg = { msg, "string" } })
  local s, e = msg:find("Vim%(%S+%):")
  if s then
    msg = msg:sub(e + 1)
  elseif vim.startswith(msg, "Vim:") then
    msg = msg:sub(#"Vim:" + 1)
  end
  M.user_error(msg)
end

return M
