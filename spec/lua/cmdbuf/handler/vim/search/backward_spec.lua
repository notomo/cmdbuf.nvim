local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/search/backward handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "vim/search/backward"

  it("can open a buffer", function()
    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://vim/search/backward-buffer")
    assert.filetype("")
  end)

  it("can search current line pattern", function()
    helper.set_lines([[search backward target]])

    cmdbuf.split_open(10, { type = typ })
    helper.set_lines([[target]])
    cmdbuf.execute({ quit = true })

    assert.cursor_word("target")
    assert.equals("target", vim.fn.getreg("/"))
    assert.equals(1, vim.v.hlsearch)
    assert.equals(0, vim.v.searchforward)
  end)

  it("adds history on execution", function()
    helper.set_lines([[search backward history]])

    cmdbuf.split_open(10, { type = typ })
    helper.set_lines([[search backward history]])
    cmdbuf.execute({ quit = true })
    cmdbuf.split_open(10, { type = typ })

    assert.exists_pattern([[^search backward history$]])
  end)

  it("shows a raw `Pattern not found` error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[invalid_search_backward]])

    cmdbuf.execute({ quit = true })

    assert.exists_message("E486: Pattern not found: invalid_search_backward")
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("search", "delete_search_backward")

    cmdbuf.open({ type = typ })
    helper.search("delete_search_backward")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_search_backward")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_search_backward")
  end)

  it("does not raise error even if command is empty line", function()
    cmdbuf.open({ type = typ })
    cmdbuf.execute()

    assert.window_count(1)
  end)

  it("can enter cmdline", function()
    helper.set_lines([[cmdline
search backward target]])
    helper.search("backward")

    vim.fn.histadd("search", "cmdline")

    cmdbuf.open({ type = typ })
    helper.search("cmdline")

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "<CR>")

    assert.exists_pattern([[^cmdline$]])
  end)
end)
