local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local messagelib = require(plugin_name .. ".vendor.message")

local M = {}
M.__index = M

function M.new(f)
  local tbl = { _return = f }
  return setmetatable(tbl, M)
end

function M.for_return_value()
  return M.new(function(f)
    local ok, result, err = xpcall(f, debug.traceback)
    if not ok then
      messagelib.error(result)
      return nil
    elseif err then
      messagelib.warn(err)
      return nil
    end
    return result
  end)
end

function M.for_return_packed_value()
  return M.new(function(f)
    local ok, result, err = xpcall(f, debug.traceback)
    if not ok then
      messagelib.error(result)
      return nil
    elseif err then
      messagelib.warn(err)
      return nil, err
    end
    return vim.F.unpack_len(result)
  end)
end

function M.for_show_error()
  return M.new(function(f)
    local ok, err = xpcall(f, debug.traceback)
    if not ok then
      messagelib.error(err)
      return nil
    elseif err then
      messagelib.warn(err)
      return nil
    end
    return nil
  end)
end

function M.methods(self)
  local methods = {}
  for key in pairs(self) do
    methods[key] = function(...)
      return self(key, ...)
    end
  end
  return methods
end

function M.__call(self, key, ...)
  local args = vim.F.pack_len(...)
  local f = function()
    return self[key](vim.F.unpack_len(args))
  end
  return self._return(f)
end

return M
