local repository = require("cmdbuf.lib.repository").Repository.new("handler")
local cursorlib = require("cmdbuf.lib.cursor")

local M = {}

local Buffer = {}
Buffer.__index = Buffer
M.Buffer = Buffer

function Buffer.open(handler, layout, line, column)
  vim.validate({
    handler = {handler, "table"},
    layout = {layout, "table"},
    line = {line, "string", true},
    column = {column, "number", true},
  })

  local name = ("cmdbuf://%s-buffer"):format(handler.name)
  local bufnr = vim.fn.bufnr(("^%s$"):format(name))
  local already_created = bufnr ~= -1
  if already_created then
    -- NOTE: the buffer is empty if it was closed by `:quit!`
    vim.fn.bufload(bufnr)
  end

  if not already_created then
    bufnr = vim.api.nvim_create_buf(false, true)

    local tbl = {
      _bufnr = bufnr,
      _handler = handler,
      _origin_window = vim.api.nvim_get_current_win(),
    }
    local buffer = setmetatable(tbl, Buffer)
    repository:set(bufnr, buffer)

    local err = buffer:load(line)
    if err ~= nil then
      return err
    end
    vim.api.nvim_buf_set_name(bufnr, name)

    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", [[<Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})
    vim.api.nvim_buf_set_keymap(bufnr, "i", "<CR>", [[<ESC><Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})

    vim.cmd(("autocmd BufReadCmd <buffer=%s> lua require('cmdbuf.command').Command.new('reload', %s)"):format(bufnr, bufnr))
    vim.cmd(("autocmd BufWipeout <buffer=%s> lua require('cmdbuf.command').Command.new('cleanup', %s)"):format(bufnr, bufnr))
  elseif line ~= nil then
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {line})
  end

  layout:open(bufnr)

  if not already_created then
    cursorlib.to_bottom(bufnr)
    vim.cmd("doautocmd <nomodeline> BufRead") -- HACK?
    vim.cmd("doautocmd <nomodeline> User CmdbufNew")
  elseif line ~= nil then
    cursorlib.to_bottom(bufnr)
  end

  if column ~= nil then
    cursorlib.set_column(column)
  end
end

function Buffer.get(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local buffer = repository:get(bufnr)
  if buffer == nil then
    error(("state is not found in buffer: %s"):format(bufnr))
  end
  return buffer
end

function Buffer.current()
  local bufnr = vim.api.nvim_get_current_buf()
  return Buffer.get(bufnr)
end

function Buffer.load(self, line)
  vim.validate({line = {line, "string", true}})

  local lines = self._handler:histories()
  table.insert(lines, line or "")
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)

  vim.bo[self._bufnr].filetype = self._handler.filetype
end

function Buffer.execute(self, row, quit)
  vim.validate({row = {row, "number"}, quit = {quit, "boolean", true}})

  local line = vim.api.nvim_buf_get_lines(self._bufnr, row - 1, row, false)[1]
  self._handler:add_history(line)

  if quit then
    self:close()
  end

  if line == "" then
    return nil
  end
  return self._handler:execute(line)
end

function Buffer.delete_range(self, s, e)
  vim.validate({s = {s, "number"}, e = {e, "number"}})
  local lines = vim.api.nvim_buf_get_lines(self._bufnr, s, e, false)
  self._handler:delete_histories(lines)
  vim.api.nvim_buf_set_lines(self._bufnr, s, e, false, {})
end

function Buffer.close()
  local win_count = #vim.api.nvim_tabpage_list_wins(0)
  if win_count > 1 then
    return vim.api.nvim_win_close(0, true)
  end

  vim.cmd("buffer #")
end

function Buffer.cleanup(self)
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(self._origin_window) then
      vim.api.nvim_set_current_win(self._origin_window)
    end
  end)
  repository:delete(self._bufnr)
end

return M
