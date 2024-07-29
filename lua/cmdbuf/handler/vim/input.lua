local historylib = require("cmdbuf.lib.history")

local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M.parse(_, line)
  return line
end

function M.histories()
  return historylib.filter_map("input", function(input)
    if input == "" then
      return nil
    end
    return input
  end)
end

function M.cmdline(_, _)
  -- not supported
  return {
    str = ":",
    column = 0,
  }
end

function M.add_history(_, line)
  vim.fn.histadd("input", line)
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    historylib.delete("input", line)
  end
end

function M.execute(_, _)
  return nil
end

M.filetype = ""

return M
