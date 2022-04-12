vim.keymap.set("n", "q:", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight)
end)
vim.keymap.set("c", "<C-f>", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", true)
end)

-- Custom buffer mappings
vim.api.nvim_create_autocmd({ "User" }, {
  group = vim.api.nvim_create_augroup("cmdbuf_setting", {}),
  pattern = { "CmdbufNew" },
  callback = function()
    vim.keymap.set("n", "q", [[<Cmd>quit<CR>]], { nowait = true, buffer = true })
    vim.keymap.set("n", "dd", [[<Cmd>lua require('cmdbuf').delete()<CR>]], { buffer = true })
  end,
})

-- open lua command-line window
vim.keymap.set("n", "ql", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "lua/cmd" })
end)

-- q/, q? alternative
vim.keymap.set("n", "q/", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "vim/search/forward" })
end)
vim.keymap.set("n", "q?", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "vim/search/backward" })
end)
