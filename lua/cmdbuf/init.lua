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
--- @param (optional) |cmdbf.nvim-open-opts|
function M.open(opts)
  return main("open", {}, opts)
end

--- Open a command buffer with `split`.
--- @param (optional) window height
--- @param (optional) |cmdbf.nvim-open-opts|
function M.split_open(height, opts)
  return main("open", {type = "split", height = height}, opts)
end

--- Open a command buffer with `vsplit`.
--- @param (optional) window width
--- @param (optional) |cmdbf.nvim-open-opts|
function M.vsplit_open(width, opts)
  return main("open", {type = "vsplit", width = width}, opts)
end

--- Open a command buffer in new tab.
--- @param (optional) |cmdbf.nvim-open-opts|
function M.tab_open(opts)
  return main("open", {type = "tab"}, opts)
end

--- Execute the current line command.
--- @param (optional) |cmdbf.nvim-execute-opts|
function M.execute(opts)
  return main("execute", opts)
end

function M._reload(bufnr)
  return main("reload", bufnr)
end

return M
