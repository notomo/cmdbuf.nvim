local Window = require("cmdbuf.core.window")

local M = {}

function M.open(opts)
  opts = require("cmdbuf.option").new_open_opts(opts)

  local handler, err = require("cmdbuf.handler").new(opts.type)
  if err then
    require("cmdbuf.vendor.misclib.message").error(err)
  end

  local buffer, created = require("cmdbuf.core.buffer").get_or_create(handler, opts.line)
  Window.open(buffer, created, opts.open_window, opts.reusable_window_ids, opts.line, opts.column)
end

function M.execute(opts)
  opts = require("cmdbuf.option").new_execute_opts(opts)
  Window.current():execute(opts.quit)
end

function M.get_context(raw_opts)
  local opts = require("cmdbuf.option").new_get_context_opts(raw_opts)
  local typ = vim.api.nvim_buf_get_name(opts.bufnr):match("cmdbuf://(.+)-buffer")
  if not typ then
    require("cmdbuf.vendor.misclib.message").error(("The buffer(%d) is not cmdbuf buffer"):format(opts.bufnr))
  end
  return {
    type = typ,
  }
end

function M.cmdline_expr()
  return Window.current():cmdline_expr()
end

function M.delete(range)
  Window.current():delete_range(range)
end

function M.close(window_id)
  Window.get(window_id):close()
end

function M.on_win_closed(window_id)
  Window.get(window_id):on_closed()
end

return M
