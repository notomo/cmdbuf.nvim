local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")
local assert = require("assertlib").typed(assert)

describe("vim/input handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "vim/input"

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://vim/input-buffer")
    assert.filetype("")
    assert.no.buffer_number(origin)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[test_input]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^test_input$]])
  end)

  it("can delete an input from history", function()
    vim.fn.histadd("input", "delete_target_input")

    cmdbuf.open({ type = typ })
    helper.search("delete_target_input")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_target_input")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_target_input")
  end)

  it("can enter cmdline", function()
    vim.fn.histadd("input", "cmdline_test_input")

    cmdbuf.open({ type = typ })

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "let b:cmdbuf_input=1<CR>")

    assert.equal(1, vim.b.cmdbuf_input)
  end)
end)
