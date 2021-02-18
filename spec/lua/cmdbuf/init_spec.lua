local helper = require("cmdbuf.lib.testlib.helper")

describe("cmdbuf.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    require("cmdbuf").open()

    assert.buffer("cmdbuf://vim/cmd-buffer")
    assert.filetype("vim")
    assert.no.bufnr(origin)
  end)

  it("can open with split", function()
    local origin = vim.api.nvim_get_current_buf()

    require("cmdbuf").split_open()

    vim.cmd("wincmd k")
    assert.bufnr(origin)

    vim.cmd("wincmd j")
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("can open with vsplit", function()
    local origin = vim.api.nvim_get_current_buf()

    require("cmdbuf").vsplit_open()

    vim.cmd("wincmd h")
    assert.bufnr(origin)

    vim.cmd("wincmd l")
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("can open in the new tab", function()
    require("cmdbuf").tab_open()

    assert.tab_count(2)
    assert.buffer("cmdbuf://vim/cmd-buffer")
  end)

  it("fills the buffer with command history", function()
    vim.fn.histadd("cmd", "history1")
    vim.fn.histadd("cmd", "history2")

    require("cmdbuf").open()

    assert.exists_pattern([[
history1
history2]])
  end)

  it("can open the same buffer more than two", function()
    require("cmdbuf").open()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("tabedit")

    require("cmdbuf").open()

    assert.bufnr(bufnr)
  end)

  it("can execute current line command", function()
    require("cmdbuf").open()
    helper.set_lines([[tabedit]])

    require("cmdbuf").execute({quit = true})

    assert.tab_count(2)
  end)

  it("can quit after command execution in no split window", function()
    require("cmdbuf").open()
    helper.set_lines([[tabedit]])

    require("cmdbuf").execute({quit = true})

    assert.tab_count(2)
  end)

  it("can quit after command execution in splitted window", function()
    require("cmdbuf").split_open()
    helper.set_lines([[tabedit]])

    require("cmdbuf").execute({quit = true})

    assert.tab_count(2)

    vim.cmd("tabprevious")
    assert.window_count(1)
  end)

  it("can execute command without quit", function()
    require("cmdbuf").open()
    helper.set_lines([[tabedit]])

    require("cmdbuf").execute()
    vim.cmd("tabprevious")
    require("cmdbuf").execute()

    assert.tab_count(3)
  end)

  it("can reload the buffer", function()
    vim.fn.histadd("cmd", "reloaded_history")
    require("cmdbuf").open()
    vim.cmd("%delete _")

    vim.cmd("edit!")

    assert.exists_pattern("reloaded_history")
  end)

  it("shows a raw command error", function()
    require("cmdbuf").open()
    helper.set_lines([[invalid_test_cmd]])

    require("cmdbuf").execute({quit = true})

    assert.exists_message("E492: Not an editor command: invalid_test_cmd")
  end)

  it("can open with line", function()
    local cmd = "tabedit"
    require("cmdbuf").open({line = cmd, column = #cmd})

    assert.current_line("tabedit")
    assert.current_row(vim.fn.line("$"))
    assert.current_col(#cmd)
  end)

  it("fires CmdbufNew on opening a new buffer", function()
    vim.cmd("autocmd User CmdbufNew ++once lua vim.b.cmdbuf_test = 'fired_cmdbuf_new!'")

    require("cmdbuf").open()

    assert.is_same("fired_cmdbuf_new!", vim.b.cmdbuf_test)
  end)

  it("can restore the buffer even if it was closed by :quit!", function()
    vim.fn.histadd("cmd", "can_restore_after_quit!")

    require("cmdbuf").split_open()
    vim.cmd("quit!")
    require("cmdbuf").split_open()

    assert.exists_pattern("can_restore_after_quit!")
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("cmd", "delete_target_cmd")

    require("cmdbuf").open()
    helper.search("delete_target_cmd")
    require("cmdbuf").delete()
    assert.no.exists_pattern("delete_target_cmd")

    vim.cmd("edit!")
    assert.no.exists_pattern("delete_target_cmd")
  end)

  it("can delete commands by given range", function()
    vim.fn.histdel("cmd", ".*")
    vim.fn.histadd("cmd", "ranged_delete_cmd1")
    vim.fn.histadd("cmd", "ranged_delete_cmd2")
    vim.fn.histadd("cmd", "ranged_delete_cmd3")
    vim.fn.histadd("cmd", "ranged_delete_cmd4")

    require("cmdbuf").open()
    require("cmdbuf").delete({2, 3})

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

end)
