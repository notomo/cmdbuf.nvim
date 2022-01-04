local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(prefix .. err)
end

function M.warn(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { prefix .. msg, "WarningMsg" } }, true, {})
end

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
