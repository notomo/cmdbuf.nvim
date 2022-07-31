local helper = require("cmdbuf.lib.testlib.helper")
local cmdbuf = helper.require("cmdbuf")

describe("vim/cmd handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a buffer", function()
    local origin = vim.api.nvim_get_current_buf()

    cmdbuf.open()

    assert.buffer("cmdbuf://vim/cmd-buffer")
    assert.filetype("vim")
    assert.no.bufnr(origin)
  end)

  it("can execute current line command", function()
    cmdbuf.open()
    helper.set_lines([[tabedit]])

    cmdbuf.execute({ quit = true })

    assert.tab_count(2)
  end)

  it("adds history on execution", function()
    cmdbuf.open()
    helper.set_lines([[1tabedit]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open()

    assert.exists_pattern([[^1tabedit$]])
  end)

  it("shows a raw `Vim:` error", function()
    cmdbuf.open()
    helper.set_lines([[invalid_test_cmd]])

    cmdbuf.execute({ quit = true })

    assert.exists_message("E492: Not an editor command: invalid_test_cmd")
  end)

  it("shows a raw `Vim(cmdname):` error", function()
    vim.bo.modifiable = false

    cmdbuf.split_open()
    helper.set_lines([[append]])

    cmdbuf.execute({ quit = true })

    assert.exists_message("E21: Cannot make changes, 'modifiable' is off")
  end)

  it("can delete a command from history", function()
    vim.fn.histadd("cmd", "delete_target_cmd")

    cmdbuf.open()
    helper.search("delete_target_cmd")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_target_cmd")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_target_cmd")
  end)
end)
