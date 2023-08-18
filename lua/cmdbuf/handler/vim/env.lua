local M = {}
M.__index = M

function M.new()
  return setmetatable({}, M)
end

function M.histories()
  local names = vim.fn.getcompletion("*", "environment")
  local key_values = {}
  for _, name in ipairs(names) do
    local key_value = ("%s=%s"):format(name, os.getenv(name):gsub("\n", "\\n"))
    table.insert(key_values, key_value)
  end
  return key_values
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
