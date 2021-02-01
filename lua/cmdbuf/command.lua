local Layout = require("cmdbuf.layout").Layout
local vim = vim

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new()
  local tbl = {_name = "cmdbuf://vim/cmd-buffer"}
  return setmetatable(tbl, Command)
end

function Command.open(self, layout_opts, opts)
  vim.validate({layout_opts = {layout_opts, "table"}, opts = {opts, "table", true}})
  opts = opts or {}

  local layout = Layout.new(layout_opts)

  local bufnr = vim.fn.bufnr(("^%s$"):format(self._name))
  local already_created = bufnr ~= -1
  if not already_created then
    bufnr = vim.api.nvim_create_buf(false, true)
    self:_load(bufnr, opts.line)
    vim.api.nvim_buf_set_name(bufnr, self._name)

    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", [[<Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})
    vim.api.nvim_buf_set_keymap(bufnr, "i", "<CR>", [[<ESC><Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})

    vim.cmd(("autocmd BufReadCmd <buffer=%s> lua require('cmdbuf')._reload(%s)"):format(bufnr, bufnr))
  elseif opts.line ~= nil then
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {opts.line})
  end

  layout:open(bufnr)

  if not already_created then
    local count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(0, {count, 0})
    vim.cmd("doautocmd BufRead") -- HACK?
  elseif opts.line ~= nil then
    local count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(0, {count, 0})
  end

  if opts.column ~= nil then
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_win_set_cursor(0, {row, opts.column - 1})
  end
end

function Command.execute(self, opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local line = vim.api.nvim_get_current_line()
  vim.fn.histadd("cmd", line)

  self:_quit(opts.quit)

  local ok, result = pcall(vim.cmd, line)
  if not ok then
    local msg = result
    if vim.startswith(msg, "Vim(echoerr)") then
      msg = msg:sub(#("Vim:(echoerr)") + 1)
    elseif vim.startswith(msg, "Vim:") then
      msg = msg:sub(#("Vim:") + 1)
    end

    vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    vim.v.errmsg = msg

    return nil, msg
  end
end

function Command._quit(_, quit)
  if not quit then
    return
  end

  local win_count = #vim.api.nvim_tabpage_list_wins(0)
  if win_count > 1 then
    return vim.cmd("quit")
  end

  vim.cmd("buffer #")
end

function Command._load(_, bufnr, line)
  local count = vim.fn.histnr("cmd")
  local cmds = {}
  for i = 1, count, 1 do
    local cmd = vim.fn.histget("cmd", i)
    if cmd ~= "" then
      table.insert(cmds, cmd)
    end
  end
  table.insert(cmds, line or "")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, cmds)

  vim.bo[bufnr].filetype = "vim"
end

function Command.reload(self, bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  self:_load(bufnr)
end

return M
