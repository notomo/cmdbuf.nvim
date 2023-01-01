local Window = require("cmdbuf.core.window")
local vim = vim

local M = {}

function M.open(layout_opts, opts)
  vim.validate({ layout_opts = { layout_opts, "table" }, opts = { opts, "table", true } })
  opts = opts or {}

  local typ = opts.type or "vim/cmd"
  local handler, err = require("cmdbuf.handler").new(typ)
  if err then
    require("cmdbuf.vendor.misclib.message").error(err)
  end

  local buffer, created = require("cmdbuf.core.buffer").get_or_create(handler, opts.line)
  local layout = require("cmdbuf.layout").new(layout_opts, opts.reusable_window_ids or {})
  Window.open(buffer, created, layout, opts.line, opts.column)
end

function M.execute(opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}
  Window.current():execute(opts.quit)
end

function M.delete(range)
  Window.current():delete_range(range)
end

function M.on_win_closed(window_id)
  Window.get(window_id):on_closed()
end

return M
