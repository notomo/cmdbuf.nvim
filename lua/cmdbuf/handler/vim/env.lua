local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M.histories()
  local keys = require("cmdbuf.lib.completion").get("*", "environment")
  local lines = {}
  for _, key in ipairs(keys) do
    local value = vim.env[key]
    if value then
      local line = ("%s=%s"):format(key, value:gsub("\n", "\\n"))
      table.insert(lines, line)
    end
  end
  return lines
end

function M.parse(_, line)
  -- not supported
  return line
end

function M.add_history(_, _) end

local extract_key_value = function(line)
  local index = line:find("=")
  if not index then
    return line
  end

  local key = line:sub(1, index - 1)
  local value = line:sub(index + 1)
  return key, value
end

function M.cmdline(_, line)
  local key, value = extract_key_value(line)
  return {
    str = (":lua vim.env[%q] = [=[%s]=]"):format(key, value),
    column = -1,
  }
end

function M.delete_histories(_, lines)
  for _, line in ipairs(lines) do
    local key, _ = extract_key_value(line)
    vim.env[key] = nil
  end
end

function M.execute(_, line)
  local key, value = extract_key_value(line)
  vim.env[key] = value
end

M.filetype = ""

return M
