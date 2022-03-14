local M = {}

--- Open a command buffer.
--- @param opts table|nil: |cmdbuf.nvim-open-opts|
function M.open(opts)
  require("cmdbuf.command").open({}, opts)
end

--- Open a command buffer with `split`.
--- @param height number|nil: window height
--- @param opts table|nil: |cmdbuf.nvim-open-opts|
function M.split_open(height, opts)
  require("cmdbuf.command").open({ type = "split", height = height }, opts)
end

--- Open a command buffer with `vsplit`.
--- @param width number|nil: window width
--- @param opts table|nil: |cmdbuf.nvim-open-opts|
function M.vsplit_open(width, opts)
  require("cmdbuf.command").open({ type = "vsplit", width = width }, opts)
end

--- Open a command buffer in new tab.
--- @param opts table|nil: |cmdbuf.nvim-open-opts|
function M.tab_open(opts)
  require("cmdbuf.command").open({ type = "tab" }, opts)
end

--- Execute the current line command.
--- @param opts table|nil: |cmdbuf.nvim-open-opts|
function M.execute(opts)
  require("cmdbuf.command").execute(opts)
end

--- Delete current line (or given range) from command history
--- @param range table|nil: 1-based range {start number, end number}
function M.delete(range)
  require("cmdbuf.command").delete(range)
end

return M
