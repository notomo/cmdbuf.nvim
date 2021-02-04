local example_path = "./spec/example.vim"

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
        local f = io.open(example_path, "r")
        local lines = {}
        for line in f:lines() do
          if line == "" then
            table.insert(lines, line)
          else
            table.insert(lines, ("  %s"):format(line))
          end
        end
        f:close()
        return (">\n%s\n<"):format(table.concat(lines, "\n"))
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(example_path, "r")
  local exmaple = f:read("*a")
  f:close()

  local content = ([[
Alternative command-line-window plugin

## Example

```vim
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
