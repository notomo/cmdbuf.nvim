local Buffer = require("cmdbuf.core.buffer").Buffer
local Window = require("cmdbuf.core.window").Window
local Layout = require("cmdbuf.layout").Layout
local Handler = require("cmdbuf.handler").Handler
local messagelib = require("cmdbuf.lib.message")
local vim = vim

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, msg = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(msg)
  elseif msg then
    return messagelib.warn(msg)
  end
end

function Command.open(layout_opts, opts)
  vim.validate({layout_opts = {layout_opts, "table"}, opts = {opts, "table", true}})
  opts = opts or {}

  local typ = opts.type or "vim/cmd"
  local handler, err = Handler.new(typ)
  if err ~= nil then
    return err
  end

  local buffer = Buffer.get_or_create(handler, opts.line)
  local layout = Layout.new(layout_opts)
  buffer:open(layout, opts.line, opts.column)
end

function Command.execute(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}
  return Window.current():execute(opts.quit)
end

function Command.delete(range)
  return Window.current():delete_range(range)
end

function Command.reload(bufnr)
  return Buffer.get(bufnr):load()
end

function Command.on_win_closed(window_id)
  return Window.get(window_id):on_closed()
end

function Command.cleanup(bufnr)
  return Buffer.get(bufnr):cleanup()
end

return M
