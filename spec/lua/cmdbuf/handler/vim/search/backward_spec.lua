local helper = require("cmdbuf.lib.testlib.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/search/backward handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    cmdbuf.open({ type = "vim/search/backward" })

    assert.buffer("cmdbuf://vim/search/backward-buffer")
    assert.filetype("")
  end)

  it("can search current line pattern", function()
    helper.set_lines([[search backward target]])

    cmdbuf.split_open(10, { type = "vim/search/backward" })
    helper.set_lines([[target]])
    cmdbuf.execute({ quit = true })

    assert.current_word("target")
    assert.equals("target", vim.fn.getreg("/"))
    assert.equals(1, vim.v.hlsearch)
    assert.equals(0, vim.v.searchforward)
  end)

  it("adds history on execution", function()
    helper.set_lines([[search backward history]])

    cmdbuf.split_open(10, { type = "vim/search/backward" })
    helper.set_lines([[search backward history]])
    cmdbuf.execute({ quit = true })
    cmdbuf.split_open(10, { type = "vim/search/backward" })

    assert.exists_pattern([[^search backward history$]])
  end)

  it("shows a raw `Pattern not found` error", function()
    cmdbuf.open({ type = "vim/search/backward" })
    helper.set_lines([[invalid_search_backward]])

    cmdbuf.execute({ quit = true })

    assert.exists_message("E486: Pattern not found: invalid_search_backward")
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("search", "delete_search_backward")

    cmdbuf.open({ type = "vim/search/backward" })
    helper.search("delete_search_backward")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_search_backward")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_search_backward")
  end)

  it("does not raise error even if command is empty line", function()
    cmdbuf.open({ type = "vim/search/backward" })
    cmdbuf.execute()

    assert.window_count(1)
  end)
end)
