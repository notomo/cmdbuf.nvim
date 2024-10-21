local modulelib = require("cmdbuf.vendor.misclib.module")

local Handler = {}

--- @param typ string
function Handler.new(typ)
  local Class = modulelib.find("cmdbuf/handler/" .. typ)
  if not Class then
    return nil, "not found handler: " .. typ
  end
  local handler = Class.new()
  handler.name = typ:gsub("%.", "/")
  return handler
end

return Handler
