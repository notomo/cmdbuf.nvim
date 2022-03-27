local modulelib = require("cmdbuf.vendor.misclib.module")

local M = {}

local Handler = {}
M.Handler = Handler

function Handler.new(typ)
  vim.validate({ type = { typ, "string" } })

  local Class = modulelib.find("cmdbuf/handler/" .. typ)
  if not Class then
    return nil, "not found handler: " .. typ
  end
  local handler = Class.new()
  handler.name = typ:gsub("%.", "/")
  return handler
end

return M
