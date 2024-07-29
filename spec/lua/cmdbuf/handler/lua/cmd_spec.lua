local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("lua/cmd handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "lua/cmd"

  it("can open a lua command buffer", function()
    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://lua/cmd-buffer")
    assert.filetype("lua")
  end)

  it("can execute current line as lua", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[vim.cmd.tabedit()]])

    cmdbuf.execute({ quit = true })

    assert.tab_count(2)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[vim.cmd.tabedit({range = {0}})]])

    cmdbuf.execute({ quit = true })
    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^vim.cmd.tabedit({range = {0}})$]])
  end)

  it("shows a raw command error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[invalid_lua_test_cmd]])

    cmdbuf.execute({ quit = true })

    assert.exists_message([[E5107: Error loading lua %[string ":lua"%]:1: '%=' expected near '<eof>']])
  end)

  it("can delete a lua command from history", function()
    vim.fn.histadd("cmd", [[lua vim.cmd.target_lua_cmd()]])

    cmdbuf.open({ type = typ })
    helper.search("target_lua_cmd")
    cmdbuf.delete()
    assert.no.exists_pattern("target_lua_cmd")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("target_lua_cmd")
  end)

  it("can delete a lua= command from history", function()
    vim.fn.histadd("cmd", [[lua=vim.cmd.target_lua_cmd()]])

    cmdbuf.open({ type = typ })
    helper.search("target_lua_cmd")
    cmdbuf.delete()
    assert.no.exists_pattern("target_lua_cmd")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("target_lua_cmd")
  end)

  it("can delete a = command from history", function()
    vim.fn.histadd("cmd", [[=vim.cmd.target_lua_cmd()]])

    cmdbuf.open({ type = typ })
    helper.search("target_lua_cmd")
    cmdbuf.delete()
    assert.no.exists_pattern("target_lua_cmd")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("target_lua_cmd")
  end)

  it("lists including lua= command", function()
    vim.fn.histadd("cmd", [[lua="equal_test"]])

    cmdbuf.open({ type = typ })
    helper.search("equal_test")

    assert.exists_pattern([["equal_test"]])
  end)

  it("lists including = command", function()
    vim.fn.histadd("cmd", [[="equal_test"]])

    cmdbuf.open({ type = typ })
    helper.search("equal_test")

    assert.exists_pattern([["equal_test"]])
  end)

  it("can enter cmdline", function()
    vim.fn.histadd("cmd", [[lua vim.b.cmdbuf_test = 8888]])

    cmdbuf.open({ type = typ })
    helper.search("8888")

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "1<CR>")

    assert.equals(18888, vim.b.cmdbuf_test)
  end)

  it("can specific lua prefixed line", function()
    cmdbuf.open({
      type = typ,
      line = "lua print(8888)",
    })

    assert.current_line("print(8888)")
  end)
end)
