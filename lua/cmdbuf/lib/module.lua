local M = {}

M.find = function(path)
  local ok, module = pcall(require, path:gsub("/", "."))
  if not ok then
    return nil
  end
  return module
end

return M
