local helper = require("cmdbuf.test.helper")
local cmdbuf = helper.require("cmdbuf")

describe("lua/variable/buffer handler", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local typ = "lua/variable/buffer"

  it("can open a lua buffer variable buffer", function()
    cmdbuf.open({ type = typ })

    assert.buffer_full_name("cmdbuf://lua/variable/buffer-buffer")
    assert.filetype("lua")
  end)

  it("can execute current line as buffer variable set command", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[execute_test = 8888]])

    cmdbuf.execute({ quit = true })

    assert.is_same(8888, vim.b.execute_test)
  end)

  it("adds history on execution", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[history_test = 8888]])

    cmdbuf.execute({ quit = true })
    vim.b.history_test = nil
    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^history_test = 8888$]])
  end)

  it("shows current buffer variables", function()
    vim.b.set_test = 8888

    cmdbuf.open({ type = typ })

    assert.exists_pattern([[^set_test = 8888$]])
  end)

  it("shows a raw command error", function()
    cmdbuf.open({ type = typ })
    helper.set_lines([[invalid_lua_test_cmd]])

    cmdbuf.execute({ quit = true })

    assert.exists_message([[E5107: Error loading lua %[string ":lua"%]:1: '%=' expected near '<eof>']])
  end)

  it("shows empty if the buffer is invalid", function()
    local bufnr = vim.api.nvim_get_current_buf()
    cmdbuf.open({ type = typ })

    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.cmd.edit({ bang = true })

    assert.no.exists_pattern("\\S")
  end)

  it("can delete a lua command from history", function()
    vim.fn.histadd("cmd", [[lua vim.b.delete_test = 8888]])

    cmdbuf.open({ type = typ })
    helper.search("delete_test")
    cmdbuf.delete()
    assert.no.exists_pattern("delete_test")

    vim.cmd.edit({ bang = true })
    assert.no.exists_pattern("delete_test")
  end)

  it("can enter cmdline", function()
    vim.fn.histadd("cmd", [[lua vim.b.cmdbuf_test = 8888]])

    cmdbuf.open({ type = typ })
    helper.search("8888")

    helper.execute_as_expr_keymap(cmdbuf.cmdline_expr() .. "1<CR>")

    assert.equals(18888, vim.b.cmdbuf_test)
  end)
end)
