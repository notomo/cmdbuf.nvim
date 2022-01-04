local M = {}

local Layouts = {}

function Layouts.no() end

function Layouts.vsplit(width)
  vim.validate({ width = { width, "number", true } })
  return function()
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    if width ~= nil then
      vim.api.nvim_win_set_width(0, width)
    end
  end
end

function Layouts.split(height)
  vim.validate({ height = { height, "number", true } })
  return function()
    vim.cmd("botright split")
    vim.cmd("wincmd j")
    if height ~= nil then
      vim.api.nvim_win_set_height(0, height)
    end
  end
end

function Layouts.tab()
  vim.cmd("tabedit")
end

local Layout = {}
Layout.__index = Layout
M.Layout = Layout

function Layout.new(opts)
  opts = opts or {}
  local typ = opts.type

  local f
  if typ == "vsplit" then
    f = Layouts.vsplit(opts.width)
  elseif typ == "split" then
    f = Layouts.split(opts.height)
  elseif typ == "tab" then
    f = Layouts.tab
  elseif not typ then
    f = Layouts.no
  else
    error("unexpected layout type: " .. typ)
  end

  local tbl = { _f = f }
  return setmetatable(tbl, Layout)
end

function Layout.open(self)
  self._f()
  return vim.api.nvim_get_current_win()
end

return M
