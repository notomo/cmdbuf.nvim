local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
M.error = function(err)
  local msg = ("[%s] %s"):format(plugin_name, err)
  vim.api.nvim_err_writeln(msg)
end

return M
