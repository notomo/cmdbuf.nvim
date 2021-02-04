local helper = require("cmdbuf.lib.testlib.helper")
local cmdbuf = require("cmdbuf")

describe("cmdbuf.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open()

    assert.buffer("cmdbuf://vim/cmd-buffer")
    assert.filetype("vim")
    assert.no.bufnr(origin)
  end)

  it("can open with split", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.split_open()

    vim.cmd("wincmd k")
    assert.bufnr(origin)

    vim.cmd("wincmd j")
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("can open with vsplit", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.vsplit_open()

    vim.cmd("wincmd h")
    assert.bufnr(origin)

    vim.cmd("wincmd l")
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("can open in the new tab", function()
    cmdbuf.tab_open()

    assert.tab_count(2)
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("fills the buffer with command history", function()
    vim.fn.histadd("cmd", "history1")
    vim.fn.histadd("cmd", "history2")

    cmdbuf.open()

    assert.exists_pattern([[
history1
history2]])
  end)

  it("can open the same buffer more than two", function()
    cmdbuf.open()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("tabedit")

    cmdbuf.open()

    assert.bufnr(bufnr)
  end)

  it("can execute current line command", function()
    cmdbuf.open()
    helper.set_lines([[tabedit]])

    cmdbuf.execute({quit = true})

    assert.tab_count(2)
  end)

  it("can quit after command execution in no split window", function()
    cmdbuf.open()
    helper.set_lines([[tabedit]])

    cmdbuf.execute({quit = true})

    assert.tab_count(2)
  end)

  it("can quit after command execution in splitted window", function()
    cmdbuf.split_open()
    helper.set_lines([[tabedit]])

    cmdbuf.execute({quit = true})

    assert.tab_count(2)

    vim.cmd("tabprevious")
    assert.window_count(1)
  end)

  it("can execute command without quit", function()
    cmdbuf.open()
    helper.set_lines([[tabedit]])

    cmdbuf.execute()
    vim.cmd("tabprevious")
    cmdbuf.execute()

    assert.tab_count(3)
  end)

  it("can reload the buffer", function()
    vim.fn.histadd("cmd", "reloaded_history")
    cmdbuf.open()
    vim.cmd("%delete _")

    vim.cmd("edit!")

    assert.exists_pattern("reloaded_history")
  end)

  it("shows a raw command error", function()
    cmdbuf.open()
    helper.set_lines([[invalid_test_cmd]])

    cmdbuf.execute({quit = true})

    assert.exists_message("E492: Not an editor command: invalid_test_cmd")
  end)

  it("can open with line", function()
    local cmd = "tabedit"
    cmdbuf.open({line = cmd, column = #cmd})

    assert.current_line("tabedit")
    assert.current_row(vim.fn.line("$"))
    assert.current_col(#cmd)
  end)

end)
