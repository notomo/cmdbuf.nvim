local Buffer = require("cmdbuf.buffer").Buffer
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

  local layout = Layout.new(layout_opts)

  return Buffer.open(handler, layout, opts.line, opts.column)
end

function Command.execute(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local row = vim.api.nvim_win_get_cursor(0)[1]
  return Buffer.current():execute(row, opts.quit)
end

function Command.delete(range)
  vim.validate({range = {range, "table", true}})

  local s, e
  if not range then
    local row = vim.api.nvim_win_get_cursor(0)[1]
    s = row - 1
    e = row
  end

  if range then
    vim.validate({["range[1]"] = {range[1], "number"}, ["range[2]"] = {range[2], "number"}})
    s = range[1] - 1
    e = range[2]
  end

  return Buffer.current():delete_range(s, e)
end

function Command.reload(bufnr)
  return Buffer.get(bufnr):load()
end

function Command.on_win_closed(bufnr)
  return Buffer.get(bufnr):on_win_closed()
end

function Command.cleanup(bufnr)
  return Buffer.get(bufnr):cleanup()
end

return M
