local M = {}

--- @class CmdbufOpenOption
--- @field column integer? initial cursor column in the buffer.
--- @field line string? set this string to the bottom line in the buffer.
--- @field open_window fun()? The window after executing this function is used.
--- @field reusable_window_ids integer[]? force to reuse the window that has the same buffer name. (default: {})
--- @field type CmdbufHandlerType? (default = "vim/cmd") |CmdbufHandlerType|

--- @alias CmdbufHandlerType
--- | '"vim/cmd"' # |q:| alternative
--- | '"vim/sesarch/forward"' # |q/| alternative
--- | '"vim/sesarch/backward"' # |q?| alternative
--- | '"lua/cmd"' # |q:| alternative for lua command
--- | '"lua/variable/buffer"' # buffer variable and command
--- | '"lua/variable/global"' # global variable and command

--- Open a command buffer.
--- @param opts CmdbufOpenOption?: |CmdbufOpenOption|
function M.open(opts)
  opts = opts or {}
  require("cmdbuf.command").open(opts)
end

--- Open a command buffer with `split`.
--- @param height integer|nil: window height
--- @param opts CmdbufOpenOption?: |CmdbufOpenOption|
function M.split_open(height, opts)
  opts = opts or {}
  opts.open_window = opts.open_window or require("cmdbuf.layout").split_layout(height)
  require("cmdbuf.command").open(opts)
end

--- Open a command buffer with `vsplit`.
--- @param width integer|nil: window width
--- @param opts CmdbufOpenOption?: |CmdbufOpenOption|
function M.vsplit_open(width, opts)
  opts = opts or {}
  opts.open_window = opts.open_window or require("cmdbuf.layout").vsplit_layout(width)
  require("cmdbuf.command").open(opts)
end

--- Open a command buffer in new tab.
--- @param opts CmdbufOpenOption?: |CmdbufOpenOption|
function M.tab_open(opts)
  opts = opts or {}
  opts.open_window = opts.open_window or require("cmdbuf.layout").tab_layout()
  require("cmdbuf.command").open(opts)
end

--- @class CmdbufExecuteOption
--- @field quit boolean? whether quit the window after execution.

--- Execute the current line command.
--- @param opts CmdbufExecuteOption?: |CmdbufExecuteOption|
function M.execute(opts)
  require("cmdbuf.command").execute(opts)
end

--- Delete current line (or given range) from command history
--- @param range integer[]?: 1-based range {start number, end number}
function M.delete(range)
  require("cmdbuf.command").delete(range)
end

return M
