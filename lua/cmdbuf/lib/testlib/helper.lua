local M = {}

local root, err = require("cmdbuf.lib.path").find_root("cmdbuf/*.lua")
if err ~= nil then
  error(err)
end
M.root = root

M.command = function(cmd)
  local _, e = pcall(vim.cmd, cmd)
  if e then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local msg = ("on %s: failed excmd `%s`\n%s"):format(pos, cmd, e)
    error(msg)
  end
end

M.before_each = function()
  require("cmdbuf.lib.cleanup")()
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
end

M.after_each = function()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.input = function(text)
  vim.api.nvim_put({text}, "c", true, true)
end

M.search = function(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local lines = table.concat(vim.fn.getbufline("%", 1, "$"), "\n")
    local msg = ("on %s: `%s` not found in buffer:\n%s"):format(pos, pattern, lines)
    assert(false, msg)
  end
  return result
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts

asserts.create("filetype"):register_eq(function()
  return vim.bo.filetype
end)

asserts.create("buffer"):register_eq(function()
  return vim.api.nvim_buf_get_name(0)
end)

asserts.create("bufnr"):register_eq(function()
  return vim.api.nvim_get_current_buf()
end)

asserts.create("tab_count"):register_eq(function()
  return vim.fn.tabpagenr("$")
end)

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("exists_pattern"):register(function(self)
  return function(_, args)
    local pattern = args[1]
    pattern = pattern:gsub("\n", "\\n")
    local result = vim.fn.search(pattern, "n")
    self:set_positive(("`%s` not found"):format(pattern))
    self:set_negative(("`%s` found"):format(pattern))
    return result ~= 0
  end
end)

asserts.create("error_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    local f = args[2]
    local _, actual = pcall(f)
    if not actual then
      self:set_positive("should be error")
      self:set_negative("should be error")
      return false
    end
    self:set_positive(("error message should end with '%s', but actual: '%s'"):format(expected, actual))
    self:set_negative(("error message should not end with '%s', but actual: '%s'"):format(expected, actual))
    return vim.endswith(actual, expected)
  end
end)

return M
