local Command = require("cmdbuf.command").Command

local M = {}

--- Open a command buffer.
--- @param (optional) |cmdbuf.nvim-open-opts|
function M.open(opts)
  Command.new("open", {}, opts)
end

--- Open a command buffer with `split`.
--- @param (optional) window height
--- @param (optional) |cmdbuf.nvim-open-opts|
function M.split_open(height, opts)
  Command.new("open", {type = "split", height = height}, opts)
end

--- Open a command buffer with `vsplit`.
--- @param (optional) window width
--- @param (optional) |cmdbuf.nvim-open-opts|
function M.vsplit_open(width, opts)
  Command.new("open", {type = "vsplit", width = width}, opts)
end

--- Open a command buffer in new tab.
--- @param (optional) |cmdbuf.nvim-open-opts|
function M.tab_open(opts)
  Command.new("open", {type = "tab"}, opts)
end

--- Execute the current line command.
--- @param (optional) |cmdbuf.nvim-execute-opts|
function M.execute(opts)
  Command.new("execute", opts)
end

--- Delete current line (or given range) from command history
--- @param (optional) 1-based range {start number, end number}
function M.delete(range)
  Command.new("delete", range)
end

return M

