local handler = require("cmdbuf.handler.vim.search.next")
local M = {flags = "b", searchforward = 0}
return setmetatable(M, {
  __index = function(_, k)
    return rawget(M, k) or handler[k]
  end,
})
