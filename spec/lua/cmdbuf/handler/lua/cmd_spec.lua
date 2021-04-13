local helper = require("cmdbuf.lib.testlib.helper")

describe("lua/cmd handler", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open a lua command buffer", function()
    require("cmdbuf").open({type = "lua/cmd"})

    assert.buffer("cmdbuf://lua/cmd-buffer")
    assert.filetype("lua")
  end)

  it("can execute current line as lua", function()
    require("cmdbuf").open({type = "lua/cmd"})
    helper.set_lines([[vim.cmd("tabedit")]])

    require("cmdbuf").execute({quit = true})

    assert.tab_count(2)
  end)

  it("shows a raw command error", function()
    require("cmdbuf").open({type = "lua/cmd"})
    helper.set_lines([[invalid_lua_test_cmd]])

    require("cmdbuf").execute({quit = true})

    assert.exists_message([[E5107: Error loading lua %[string ":lua"%]:1: '%=' expected near '<eof>']])
  end)

  it("can delete a lua command from history", function()
    vim.fn.histadd("cmd", [[lua vim.cmd("target_lua_cmd")]])

    require("cmdbuf").open({type = "lua/cmd"})
    helper.search("target_lua_cmd")
    require("cmdbuf").delete()
    assert.no.exists_pattern("target_lua_cmd")

    vim.cmd("edit!")
    assert.no.exists_pattern("target_lua_cmd")
  end)

end)
