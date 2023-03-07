local M = {}

--- Find specified module.
--- @param path string: for `require()` argument
--- @return any # If the module is not found, return nil.
function M.find(path)
  path = path:gsub("/", ".")
  local ok, result = pcall(require, path)
  if ok then
    return result
  end
  if vim.startswith(result, ([[module '%s' not found:]]):format(path)) then
    return nil
  end
  error(result)
end

return M
