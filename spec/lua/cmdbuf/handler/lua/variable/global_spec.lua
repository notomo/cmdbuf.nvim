local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("lua/variable/global handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "lua/variable/global"

  it("can open a lua global variable buffer", function()
    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://lua/variable/global-buffer")
    assert.filetype("lua")
  end)

  it("can execute current line as set global variable command", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[execute_test = 8888]])

    cmdbuf.execute({ quit = true })

    assert.is_same(8888, vim.g.execute_test)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[history_test = 8888]])

    cmdbuf.execute({ quit = true })
    vim.g.history_test = nil
    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^history_test = 8888$]])
  end)

  it("shows global variables", function()
    vim.g.set_test = 8888

    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^set_test = 8888$]])
  end)

  it("shows a raw command error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[invalid_lua_test_cmd]])

    cmdbuf.execute({ quit = true })

    assert.exists_message([[E5107: Error loading lua %[string ":lua"%]:1: '%=' expected near '<eof>']])
  end)

  it("can delete a lua command from history", function()
    vim.fn.histadd("cmd", [[lua vim.g.delete_test = 8888]])

    cmdbuf.open({ type = typ })
    helper.search("delete_test")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_test")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_test")
  end)

  it("can enter cmdline", function()
    vim.fn.histadd("cmd", [[lua vim.g.cmdbuf_global_test = 8888]])

    cmdbuf.open({ type = typ })
    helper.search("cmdbuf_global_test")
    helper.search("8888")

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "1<CR>")

    assert.equals(18888, vim.g.cmdbuf_global_test)
  end)

  it("can specific lua prefixed line", function()
    cmdbuf.open({
      type = typ,
      line = "lua vim.g.test=1",
    })

    assert.current_line("test=1")
  end)
end)
