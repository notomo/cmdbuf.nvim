local helper = require("cmdbuf.lib.testlib.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/search/previous handler", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    cmdbuf.open({type = "vim/search/previous"})

    assert.buffer("cmdbuf://vim/search/previous-buffer")
    assert.filetype("")
  end)

  it("can search current line pattern", function()
    helper.set_lines([[search previous target]])

    cmdbuf.split_open(10, {type = "vim/search/previous"})
    helper.set_lines([[target]])
    cmdbuf.execute({quit = true})

    assert.current_word("target")
    assert.equals("target", vim.fn.getreg("/"))
    assert.equals(1, vim.v.hlsearch)
    assert.equals(0, vim.v.searchforward)
  end)

  it("adds history on execution", function()
    helper.set_lines([[search previous history]])

    cmdbuf.split_open(10, {type = "vim/search/previous"})
    helper.set_lines([[search previous history]])
    cmdbuf.execute({quit = true})
    cmdbuf.split_open(10, {type = "vim/search/previous"})

    assert.exists_pattern([[^search previous history$]])
  end)

  it("shows a raw `Pattern not found` error", function()
    cmdbuf.open({type = "vim/search/previous"})
    helper.set_lines([[invalid_search_previous]])

    cmdbuf.execute({quit = true})

    assert.exists_message("E486: Pattern not found: invalid_search_previous")
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("search", "delete_search_previous")

    cmdbuf.open({type = "vim/search/previous"})
    helper.search("delete_search_previous")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_search_previous")

    vim.cmd("edit!")
    assert.no.exists_pattern("delete_search_previous")
  end)

end)
