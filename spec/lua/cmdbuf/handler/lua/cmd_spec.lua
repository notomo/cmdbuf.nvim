local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("lua/cmd handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a lua command buffer", function()
    cmdbuf.open({ type = "lua/cmd" })

    assert.buffer_full_name("cmdbuf://lua/cmd-buffer")
    assert.filetype("lua")
  end)

  it("can execute current line as lua", function()
    cmdbuf.open({ type = "lua/cmd" })
    helper.set_lines([[vim.cmd.tabedit()]])

    cmdbuf.execute({ quit = true })

    assert.tab_count(2)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = "lua/cmd" })
    helper.set_lines([[vim.cmd.tabedit({range = {0}})]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = "lua/cmd" })

    assert.exists_pattern([[^vim.cmd.tabedit({range = {0}})$]])
  end)

  it("shows a raw command error", function()
    cmdbuf.open({ type = "lua/cmd" })
    helper.set_lines([[invalid_lua_test_cmd]])

    cmdbuf.execute({ quit = true })

    assert.exists_message([[E5107: Error loading lua %[string ":lua"%]:1: '%=' expected near '<eof>']])
  end)

  it("can delete a lua command from history", function()
    vim.fn.histadd("cmd", [[lua vim.cmd.target_lua_cmd()]])

    cmdbuf.open({ type = "lua/cmd" })
    helper.search("target_lua_cmd")
    cmdbuf.delete()
    assert.no.exists_pattern("target_lua_cmd")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("target_lua_cmd")
  end)

  it("lists including lua= command", function()
    vim.fn.histadd("cmd", [[lua="equal_test"]])

    cmdbuf.open({ type = "lua/cmd" })
    helper.search("equal_test")

    assert.exists_pattern([["equal_test"]])
  end)

  it("lists including = command", function()
    vim.fn.histadd("cmd", [[="equal_test"]])

    cmdbuf.open({ type = "lua/cmd" })
    helper.search("equal_test")

    assert.exists_pattern([["equal_test"]])
  end)
end)
