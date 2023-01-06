local M = {}

M.default_open_opts = {
  type = "vim/cmd",
  line = nil,
  column = nil,
  reusable_window_ids = {},
}
function M.new_open_opts(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", M.default_open_opts, raw_opts)
end

M.default_execute_opts = {
  quit = false,
}
function M.new_execute_opts(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", M.default_execute_opts, raw_opts)
end

return M
