local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("vusted.assert").register)

helper.cleanup()

function helper.before_each() end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.input(text)
  vim.api.nvim_put({ text }, "c", true, true)
end

function helper.execute_as_expr_keymap(expr)
  local key = "[fire]"
  vim.keymap.set("n", key, function()
    return expr
  end, { buffer = true, expr = true, silent = true })
  vim.api.nvim_feedkeys(key, "rx", true)
end

function helper.search(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local lines = table.concat(vim.fn.getbufline("%", 1, "$"), "\n")
    local msg = ("on %s: `%s` not found in buffer:\n%s"):format(pos, pattern, lines)
    assert(false, msg)
  end
  return result
end

return helper
