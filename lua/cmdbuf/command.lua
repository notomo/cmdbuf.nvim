local Buffer = require("cmdbuf.core.buffer").Buffer
local Window = require("cmdbuf.core.window").Window
local Layout = require("cmdbuf.layout").Layout
local Handler = require("cmdbuf.handler").Handler
local ShowError = require("cmdbuf.vendor.misclib.error_handler").for_show_error()
local vim = vim

function ShowError.open(layout_opts, opts)
  vim.validate({ layout_opts = { layout_opts, "table" }, opts = { opts, "table", true } })
  opts = opts or {}

  local typ = opts.type or "vim/cmd"
  local handler, err = Handler.new(typ)
  if err then
    return err
  end

  local buffer, created = Buffer.get_or_create(handler, opts.line)
  local layout = Layout.new(layout_opts)
  Window.open(buffer, created, layout, opts.line, opts.column)
end

function ShowError.execute(opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}
  return Window.current():execute(opts.quit)
end

function ShowError.delete(range)
  return Window.current():delete_range(range)
end

function ShowError.on_win_closed(window_id)
  return Window.get(window_id):on_closed()
end

return ShowError:methods()
