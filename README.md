# cmdbuf.nvim

[![ci](https://github.com/notomo/cmdbuf.nvim/workflows/ci/badge.svg?branch=main)](https://github.com/notomo/cmdbuf.nvim/actions?query=workflow%3Aci+branch%3Amain)

The builtin command-line window is a special window.  
For example, you cannot leave it by `wincmd`.  
This plugin provides command-line window functions by normal buffer and window.  

<img src="https://raw.github.com/wiki/notomo/cmdbuf.nvim/image/demo.gif">

## Example

```lua
vim.keymap.set("n", "q:", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight)
end)
vim.keymap.set("c", "<C-f>", function()
  require("cmdbuf").split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
  vim.api.nvim_feedkeys(vim.keycode("<C-c>"), "n", true)
end)

-- Custom buffer mappings
vim.api.nvim_create_autocmd({ "User" }, {
  group = vim.api.nvim_create_augroup("config.cmdbuf", {}),
  pattern = { "CmdbufNew" },
  callback = function(args)
    vim.bo.bufhidden = "wipe" -- if you don't need previous opened buffer state
    vim.keymap.set("n", "q", [[<Cmd>quit<CR>]], { nowait = true, buffer = true })
    vim.keymap.set("n", "dd", [[<Cmd>lua require('cmdbuf').delete()<CR>]], { buffer = true })
    vim.keymap.set({ "n", "i" }, "<C-c>", function()
      return require("cmdbuf").cmdline_expr()
    end, { buffer = true, expr = true })

    local typ = require("cmdbuf").get_context().type
    if typ == "vim/cmd" then
      -- you can filter buffer lines
      local lines = vim
        .iter(vim.api.nvim_buf_get_lines(args.buf, 0, -1, false))
        :filter(function(line)
          return line ~= "q"
        end)
        :totable()
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
    end
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
```