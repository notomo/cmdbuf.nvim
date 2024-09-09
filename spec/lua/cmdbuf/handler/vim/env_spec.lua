local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")
local assert = require("assertlib").typed(assert)

describe("vim/env handler", function()
  before_each(function()
    vim.env.CMDBUF_TEST = nil
    helper.before_each()
  end)
  after_each(helper.after_each)

  local typ = "vim/env"

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://vim/env-buffer")
    assert.filetype("")
    assert.no.buffer_number(origin)
  end)

  it("sets environment variable on execution", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[CMDBUF_TEST=value]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^CMDBUF_TEST=value$]])
  end)

  it("can unset variable by delete", function()
    vim.env.CMDBUF_TEST = "delete_target"

    cmdbuf.open({ type = typ })
    helper.search("delete_target")
    cmdbuf.delete()
    assert.no.exists_pattern("CMDBUF_TEST=delete_target")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("CMDBUF_TEST=delete_target")
  end)

  it("can enter cmdline", function()
    vim.env.CMDBUF_CMDLINE_TEST = "cmdline"

    cmdbuf.open({ type = typ })

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "<CR>")

    assert.equal("cmdline", vim.env.CMDBUF_CMDLINE_TEST)
  end)
end)
