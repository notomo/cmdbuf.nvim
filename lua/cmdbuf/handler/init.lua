local modulelib = require("cmdbuf.lib.module")

local M = {}

local Handler = {}
M.Handler = Handler

function Handler.new(typ)
  vim.validate({ type = { typ, "string" } })

  local handler = modulelib.find("cmdbuf/handler/" .. typ)
  if not handler then
    return nil, "not found handler: " .. typ
  end

  local tbl = { _handler = handler, name = typ:gsub("%.", "/") }
  return setmetatable(tbl, Handler)
end

function Handler.__index(self, k)
  return rawget(Handler, k) or self._handler[k]
end

return M
