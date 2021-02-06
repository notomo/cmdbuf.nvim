local Layout = require("cmdbuf.layout").Layout
local Buffer = require("cmdbuf.buffer").Buffer
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
  end
end

function Command.open(layout_opts, opts)
  vim.validate({layout_opts = {layout_opts, "table"}, opts = {opts, "table", true}})
  opts = opts or {}

  local layout = Layout.new(layout_opts)
  Buffer.open(layout, opts.line, opts.column)
end

function Command.execute(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local line = vim.api.nvim_get_current_line()
  vim.fn.histadd("cmd", line)

  if opts.quit then
    Buffer.close()
  end

  local ok, result = pcall(vim.cmd, line)
  if not ok then
    local msg = result
    if vim.startswith(msg, "Vim(echoerr)") then
      msg = msg:sub(#("Vim:(echoerr)") + 1)
    elseif vim.startswith(msg, "Vim:") then
      msg = msg:sub(#("Vim:") + 1)
    end

    vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    vim.v.errmsg = msg
  end
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

  local lines = vim.api.nvim_buf_get_lines(0, s, e, false)
  for _, line in ipairs(lines) do
    vim.fn.histdel("cmd", ("^%s$"):format(vim.fn.escape(line, "[]\\*")))
  end
  vim.api.nvim_buf_set_lines(0, s, e, false, {})
end

function Command.reload(bufnr)
  Buffer.load(bufnr)
end

return M
