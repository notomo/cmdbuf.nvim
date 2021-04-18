local M = {}

function M.find(path)
  local ok, module = pcall(require, path:gsub("/", "."))
  if not ok then
    return nil
  end
  return module
end

return M
