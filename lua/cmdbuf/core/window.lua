local Buffer = require("cmdbuf.core.buffer")
local cursorlib = require("cmdbuf.vendor.misclib.cursor")

local _windows = {}

--- @class CmdbufWindow
--- @field private _buffer CmdbufBuffer
local Window = {}
Window.__index = Window

function Window.open(buffer, created, open_window, reusable_window_ids, line, column)
  local origin_window_id = vim.api.nvim_get_current_win()

  local buffer_name = buffer:name()
  local window_id = require("cmdbuf.layout").open(open_window, reusable_window_ids, buffer_name)

  buffer:set_to(window_id)
  _windows[window_id] = origin_window_id

  if created then
    cursorlib.to_bottom(window_id)
    vim.api.nvim_exec_autocmds("BufRead", { modeline = false }) -- HACK?
    vim.api.nvim_exec_autocmds("User", { pattern = "CmdbufNew", modeline = false })
  elseif line then
    cursorlib.to_bottom(window_id)
  end
  if column then
    cursorlib.set_column(column - 1)
  end
end

function Window.current()
  local window_id = vim.api.nvim_get_current_win()
  return Window.get(window_id)
end

function Window.get(window_id)
  vim.validate({ window_id = { window_id, "number" } })
  local bufnr = vim.api.nvim_win_get_buf(window_id)
  local origin_window_id = _windows[window_id]
  local tbl = {
    _window_id = window_id,
    _buffer = Buffer.get(bufnr),
    _origin_window_id = origin_window_id,
  }
  return setmetatable(tbl, Window)
end

function Window.execute(self, quit)
  local close_window
  if not quit then
    close_window = function() end
  else
    close_window = function()
      self:close()
    end
  end

  local row = vim.api.nvim_win_get_cursor(self._window_id)[1]
  return self._buffer:execute(row, close_window)
end

function Window.cmdline_expr(self)
  local pos = vim.api.nvim_win_get_cursor(self._window_id)
  local cmdline = self._buffer:cmdline(pos[1])

  local mode = vim.api.nvim_get_mode().mode
  local enter_normal_mode_cmd
  if mode == "i" then
    enter_normal_mode_cmd = "<ESC>"
  else
    enter_normal_mode_cmd = ""
  end

  local set_pos_cmd = ""
  if cmdline.column == -1 then
    set_pos_cmd = ([[<End>]]):format(cmdline.column + pos[2] + 1)
  else
    local column = cmdline.column or 0
    set_pos_cmd = ([[<C-R>=setcmdpos(%d)<CR><BS>]]):format(column + pos[2] + 1)
  end

  local close_cmd = ([[:<C-u>lua require("cmdbuf.command").close(%s)<CR>]]):format(self._window_id)
  return enter_normal_mode_cmd .. close_cmd .. cmdline.str .. set_pos_cmd
end

function Window.delete_range(self, range)
  vim.validate({ range = { range, "table", true } })

  local s, e
  if not range then
    local row = vim.api.nvim_win_get_cursor(self._window_id)[1]
    s = row - 1
    e = row
  end

  if range then
    vim.validate({ ["range[1]"] = { range[1], "number" }, ["range[2]"] = { range[2], "number" } })
    s = range[1] - 1
    e = range[2]
  end

  self._buffer:delete_range(s, e)
end

function Window.close(self)
  local window_count = #vim.api.nvim_tabpage_list_wins(0)
  if window_count == 1 then
    return vim.cmd.buffer("#")
  end

  self:on_closed()
  vim.api.nvim_win_close(self._window_id, true)
end

function Window.on_closed(self)
  if self._origin_window_id and vim.api.nvim_win_is_valid(self._origin_window_id) then
    vim.api.nvim_set_current_win(self._origin_window_id)
  end
  _windows[self._window_id] = nil
end

return Window
