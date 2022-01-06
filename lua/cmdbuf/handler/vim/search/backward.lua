local handler = require("cmdbuf.handler.vim.search.forward")

local M = {}

function M.new()
  return setmetatable(M, {
    __index = function(_, k)
      return rawget(M, k) or handler[k]
    end,
  })
end

M.flags = "b"
M.searchforward = 0

return M
