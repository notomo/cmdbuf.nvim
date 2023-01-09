local util = require("genvdoc.util")
local plugin_name = vim.env.PLUGIN_NAME

local example_path = ("./spec/lua/%s/example.lua"):format(plugin_name)
dofile(example_path)

require("genvdoc").generate(plugin_name .. ".nvim", {
  source = { patterns = { ("lua/%s/init.lua"):format(plugin_name) } },
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "OPTIONS",
      body = function(ctx)
        local open_opts_text
        do
          local descriptions = {
            line = [[(number | nil): set this string to the bottom line in the buffer.]],
            column = [[(number | nil): initial cursor column in the buffer.]],
            reusable_window_ids = [[(list | nil): force to reuse the window that has the same buffer name. (default: {})]],
            open_window = [[(function | nil): The window after executing this function is used.]],
            type = [[(string | nil): handler type (default = "vim/cmd")
  - `vim/cmd`: |q:| alternative
  - `vim/sesarch/forward`: |q/| alternative
  - `vim/sesarch/backward`: |q?| alternative
  - `lua/cmd`: |q:| alternative for lua command
  - `lua/variable/buffer`: buffer variable and command]],
          }
          local keys = vim.tbl_keys(descriptions)
          local lines = util.each_keys_description(keys, descriptions)
          open_opts_text = table.concat(lines, "\n")
        end

        local execute_opts_text
        do
          local descriptions = {
            quit = [[(boolean | nil): whether quit the window after execution.]],
          }
          local keys = vim.tbl_keys(descriptions)
          local lines = util.each_keys_description(keys, descriptions)
          execute_opts_text = table.concat(lines, "\n")
        end

        return util.sections(ctx, {
          { name = "|cmdbuf.open()| options", tag_name = "open-opts", text = open_opts_text },
          { name = "|cmdbuf.execute()| options", tag_name = "execute-opts", text = execute_opts_text },
        })
      end,
    },
    {
      name = "AUTOCOMMANDS",
      body = function()
        return [[
CmdbufNew                                              *cmdbuf.nvim-CmdbufNew*
  This is fired after creating a new cmdbuf.]]
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        return require("genvdoc.util").help_code_block_from_file(example_path, { language = "lua" })
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(example_path, "r")
  local exmaple = f:read("*a")
  f:close()

  local content = ([[
# cmdbuf.nvim

[![ci](https://github.com/notomo/cmdbuf.nvim/workflows/ci/badge.svg?branch=main)](https://github.com/notomo/cmdbuf.nvim/actions?query=workflow%%3Aci+branch%%3Amain)

The builtin command-line window is a special window.  
For example, you cannot leave it by `wincmd`.  
This plugin provides command-line window functions by normal buffer and window.  

<img src="https://raw.github.com/wiki/notomo/cmdbuf.nvim/image/demo.gif">

## Example

```lua
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
