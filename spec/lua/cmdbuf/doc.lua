local example_path = "./spec/lua/cmdbuf/example.vim"

local ok, result = pcall(vim.cmd, "source" .. example_path)
if not ok then
  error(result)
end

require("genvdoc").generate("cmdbuf.nvim", {
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
      body = function()
        -- TODO: use doc builder
        return [[
For `open` function                                    *cmdbuf.nvim-open-opts*
  - `line`: set this string to the bottom line in the buffer.
  - `column`: initial cursor column in the buffer.

For `execute` function                              *cmdbuf.nvim-execute-opts*
  - `quit`: whether quit the window after execution.]]
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
        return require("genvdoc.util").help_code_block_from_file(example_path)
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

Alternative command-line-window plugin

## Example

```vim
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
