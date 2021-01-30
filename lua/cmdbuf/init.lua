local Command = require("cmdbuf.command").Command
local messagelib = require("cmdbuf.lib.message")

local main = function(name, ...)
  local args = {...}
  local f = function()
    local cmd = Command.new()
    return cmd[name](cmd, unpack(args))
  end

  local _, err, msg = xpcall(f, debug.traceback)
  if err ~= nil then
    return messagelib.error(err)
  end

  return msg
end

local M = {}

--- Open a command buffer.
function M.open()
  return main("open")
end

--- Open a command buffer with `split`.
--- @param (optional) window height
function M.split_open(height)
  return main("open", {layout = {type = "split", height = height}})
end

--- Open a command buffer with `vsplit`.
--- @param (optional) window width
function M.vsplit_open(width)
  return main("open", {layout = {type = "vsplit", width = width}})
end

--- Open a command buffer in new tab.
function M.tab_open()
  return main("open", {layout = {type = "tab"}})
end

--- Execute the current line command.
--- @param (optional) `quit`: whether quit the window after execution.
function M.execute(opts)
  return main("execute", opts)
end

function M._reload(bufnr)
  return main("reload", bufnr)
end

return M
