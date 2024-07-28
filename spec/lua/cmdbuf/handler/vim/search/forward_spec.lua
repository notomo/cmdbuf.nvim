local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/search/forward handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "vim/search/forward"

  it("can open a buffer", function()
    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://vim/search/forward-buffer")
    assert.filetype("")
  end)

  it("can search current line pattern", function()
    helper.set_lines([[search forward target]])

    cmdbuf.split_open(10, { type = typ })
    helper.set_lines([[target]])
    cmdbuf.execute({ quit = true })

    assert.cursor_word("target")
    assert.equals("target", vim.fn.getreg("/"))
    assert.equals(1, vim.v.hlsearch)
    assert.equals(1, vim.v.searchforward)
  end)

  it("adds history on execution", function()
    helper.set_lines([[search forward history]])

    cmdbuf.split_open(10, { type = typ })
    helper.set_lines([[search forward history]])
    cmdbuf.execute({ quit = true })
    cmdbuf.split_open(10, { type = typ })

    assert.exists_pattern([[^search forward history$]])
  end)

  it("shows a raw `Pattern not found` error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[invalid_search_forward]])

    cmdbuf.execute({ quit = true })

    assert.exists_message("E486: Pattern not found: invalid_search_forward")
  end)

  it("shows a raw regexp error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[\z]])

    cmdbuf.execute({ quit = true })

    assert.exists_message([[^E867: %(NFA%) Unknown operator]])
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("search", "delete_search_forward")

    cmdbuf.open({ type = typ })
    helper.search("delete_search_forward")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_search_forward")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_search_forward")
  end)

  it("can enter cmdline", function()
    helper.set_lines([[search forward target
cmdline]])
    vim.fn.histadd("search", "cmdline")

    cmdbuf.open({ type = typ })
    helper.search("cmdline")

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "<CR>")

    assert.exists_pattern([[^cmdline$]])
  end)
end)
