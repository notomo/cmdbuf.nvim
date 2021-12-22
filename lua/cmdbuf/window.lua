local Buffer = require("cmdbuf.buffer").Buffer

local M = {}

local Window = {}
Window.__index = Window
M.Window = Window

function Window.current()
  local window_id = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local tbl = {_window_id = window_id, _buffer = Buffer.get(bufnr)}
  return setmetatable(tbl, Window)
end

function Window.execute(self, quit)
  local close_window
  if not quit then
    close_window = function()
    end
  else
    close_window = function()
      self:close()
    end
  end

  local row = vim.api.nvim_win_get_cursor(self._window_id)[1]
  return self._buffer:execute(row, close_window)
end

function Window.delete_range(self, range)
  vim.validate({range = {range, "table", true}})

  local s, e
  if not range then
    local row = vim.api.nvim_win_get_cursor(self._window_id)[1]
    s = row - 1
    e = row
  end

  if range then
    vim.validate({["range[1]"] = {range[1], "number"}, ["range[2]"] = {range[2], "number"}})
    s = range[1] - 1
    e = range[2]
  end

  return self._buffer:delete_range(s, e)
end

function Window.close(self)
  local window_count = #vim.api.nvim_tabpage_list_wins(0)
  if window_count == 1 then
    return vim.cmd("buffer #")
  end

  self._buffer:on_win_closed()
  vim.api.nvim_win_close(self._window_id, true)
end

return M
