local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/input handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open({ type = "vim/input" })

    assert.buffer_full_name("cmdbuf://vim/input-buffer")
    assert.filetype("")
    assert.no.buffer_number(origin)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = "vim/input" })
    helper.set_lines([[test_input]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = "vim/input" })

    assert.exists_pattern([[^test_input$]])
  end)

  it("can delete an input from history", function()
    vim.fn.histadd("input", "delete_target_input")

    cmdbuf.open({ type = "vim/input" })
    helper.search("delete_target_input")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_target_input")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_target_input")
  end)
end)
