local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/env handler", function()
  before_each(function()
    vim.env.CMDBUF_TEST = nil
    helper.before_each()
  end)
  after_each(helper.after_each)

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open({ type = "vim/env" })

    assert.buffer_full_name("cmdbuf://vim/env-buffer")
    assert.filetype("")
    assert.no.buffer_number(origin)
  end)

  it("sets environment variable on execution", function()
    cmdbuf.open({ type = "vim/env" })
    helper.set_lines([[CMDBUF_TEST=value]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = "vim/env" })

    assert.exists_pattern([[^CMDBUF_TEST=value$]])
  end)

  it("can unset variable by delete", function()
    vim.env.CMDBUF_TEST = "delete_target"

    cmdbuf.open({ type = "vim/env" })
    helper.search("delete_target")
    cmdbuf.delete()
    assert.no.exists_pattern("CMDBUF_TEST=delete_target")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("CMDBUF_TEST=delete_target")
  end)
end)
