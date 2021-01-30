local M = {}

local Layouts = {
  no = function()
  end,
  vsplit = function(width)
    vim.validate({width = {width, "number", true}})
    return function()
      vim.cmd("vsplit")
      vim.cmd("wincmd l")
      if width ~= nil then
        vim.api.nvim_win_set_width(0, width)
      end
    end
  end,
  split = function(height)
    vim.validate({height = {height, "number", true}})
    return function()
      vim.cmd("split")
      vim.cmd("wincmd j")
      if height ~= nil then
        vim.api.nvim_win_set_height(0, height)
      end
    end
  end,
  tab = function()
    vim.cmd("tabedit")
  end,
}

local Layout = {}
Layout.__index = Layout
M.Layout = Layout

function Layout.new(opts)
  opts = opts or {}
  local typ = opts.type

  local f = Layouts.no
  if typ == "vsplit" then
    f = Layouts.vsplit(opts.width)
  elseif typ == "split" then
    f = Layouts.split(opts.height)
  elseif typ == "tab" then
    f = Layouts.tab
  end

  local tbl = {_f = f}
  return setmetatable(tbl, Layout)
end

function Layout.open(self, bufnr)
  self._f()
  vim.api.nvim_win_set_buf(0, bufnr)
end

return M
