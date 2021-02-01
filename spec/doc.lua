local gen = function()
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
          return [[
For `open` function                                    *cmdbuf.nvim-open-opts*
  - `line`: set this string to the bottom line in the buffer.
  - `column`: initial cursor column in the buffer.

For `execute` function                              *cmdbuf.nvim-execute-opts*
  - `quit`: whether quit the window after execution.]]
        end,
      },
      {
        name = "EXAMPLES",
        body = function()
          local f = io.open("./spec/example.vim", "r")
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
end

gen()
