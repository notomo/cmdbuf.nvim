local helper = require("cmdbuf.lib.testlib.helper")
local cmdbuf = helper.require("cmdbuf")

describe("cmdbuf.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open with split", function()
    local origin = vim.api.nvim_get_current_buf()

    local origin_win1 = vim.api.nvim_get_current_win()
    vim.cmd("vsplit")
    local origin_win2 = vim.api.nvim_get_current_win()

    cmdbuf.split_open()

    vim.cmd("wincmd k")
    assert.bufnr(origin)

    vim.api.nvim_set_current_win(origin_win1)
    vim.cmd("wincmd j")
    assert.buffer("cmdbuf://vim/cmd-buffer")

    vim.api.nvim_set_current_win(origin_win2)
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

  it("can open with line", function()
    local cmd = "tabedit"
    cmdbuf.open({line = cmd, column = #cmd})

    assert.current_line("tabedit")
    assert.current_row(vim.fn.line("$"))
    assert.current_col(#cmd)
  end)

  it("fires CmdbufNew on opening a new buffer", function()
    vim.cmd("autocmd User CmdbufNew ++once lua vim.b.cmdbuf_test = 'fired_cmdbuf_new!'")

    cmdbuf.open()

    assert.is_same("fired_cmdbuf_new!", vim.b.cmdbuf_test)
  end)

  it("can restore the buffer even if it was closed by :quit!", function()
    vim.fn.histadd("cmd", "can_restore_after_quit!")

    cmdbuf.split_open()
    vim.cmd("quit!")
    cmdbuf.split_open()

    assert.exists_pattern("can_restore_after_quit!")
  end)

  it("can delete commands by given range", function()
    vim.fn.histdel("cmd", ".*")
    vim.fn.histadd("cmd", "ranged_delete_cmd1")
    vim.fn.histadd("cmd", "ranged_delete_cmd2")
    vim.fn.histadd("cmd", "ranged_delete_cmd3")
    vim.fn.histadd("cmd", "ranged_delete_cmd4")

    cmdbuf.open()
    cmdbuf.delete({2, 3})

    assert.exists_pattern("ranged_delete_cmd1")
    assert.no.exists_pattern("ranged_delete_cmd2")
    assert.no.exists_pattern("ranged_delete_cmd3")
    assert.exists_pattern("ranged_delete_cmd4")

    vim.cmd("edit!")

    assert.exists_pattern("ranged_delete_cmd1")
    assert.no.exists_pattern("ranged_delete_cmd2")
    assert.no.exists_pattern("ranged_delete_cmd3")
    assert.exists_pattern("ranged_delete_cmd4")
  end)

  it("can reopen after wipeout", function()
    vim.fn.histadd("cmd", "can_reopen")

    cmdbuf.vsplit_open()
    vim.cmd("bwipeout")
    cmdbuf.vsplit_open()

    assert.exists_pattern("can_reopen")
  end)

  it("restores current window on wiped", function()
    vim.cmd("vsplit")
    vim.cmd("wincmd w")
    local origin_win = vim.api.nvim_get_current_win()

    cmdbuf.split_open()
    vim.cmd("bwipeout")

    -- wait vim.schedule
    vim.wait(100, function()
      return false
    end, 10, false)

    assert.window(origin_win)
  end)

end)
