local cursorlib = require("cmdbuf.lib.cursor")

local M = {}

local Buffer = {}
Buffer.__index = Buffer
M.Buffer = Buffer

function Buffer.open(layout, line, column)
  vim.validate({
    layout = {layout, "table"},
    line = {line, "string", true},
    column = {column, "number", true},
  })

  local name = "cmdbuf://vim/cmd-buffer"
  local bufnr = vim.fn.bufnr(("^%s$"):format(name))
  local already_created = bufnr ~= -1
  if already_created then
    -- NOTE: the buffer is empty if it was closed by `:quit!`
    vim.fn.bufload(bufnr)
  end

  if not already_created then
    bufnr = vim.api.nvim_create_buf(false, true)
    Buffer.load(bufnr, line)
    vim.api.nvim_buf_set_name(bufnr, name)

    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", [[<Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})
    vim.api.nvim_buf_set_keymap(bufnr, "i", "<CR>", [[<ESC><Cmd>lua require("cmdbuf").execute({quit = true})<CR>]], {})

    vim.cmd(("autocmd BufReadCmd <buffer=%s> lua require('cmdbuf.command').Command.new('reload', %s)"):format(bufnr, bufnr))
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

function Buffer.load(bufnr, line)
  vim.validate({bufnr = {bufnr, "number"}, line = {line, "string", true}})

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

function Buffer.close()
  local win_count = #vim.api.nvim_tabpage_list_wins(0)
  if win_count > 1 then
    return vim.api.nvim_win_close(0, true)
  end

  vim.cmd("buffer #")
end

return M
