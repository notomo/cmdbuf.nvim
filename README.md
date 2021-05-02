# cmdbuf.nvim

[![ci](https://github.com/notomo/cmdbuf.nvim/workflows/ci/badge.svg?branch=main)](https://github.com/notomo/cmdbuf.nvim/actions?query=workflow%3Aci+branch%3Amain)

The builtin command-line window is a special window.
For example, you cannot leave it by `wincmd`.
This plugin provides command-line window functions by normal buffer and window.

<img src="https://raw.github.com/wiki/notomo/cmdbuf.nvim/image/demo.gif" width="1280">

## Example

```vim
nnoremap q: <Cmd>lua require('cmdbuf').split_open(vim.o.cmdwinheight)<CR>
cnoremap <C-f> <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {line = vim.fn.getcmdline(), column = vim.fn.getcmdpos()}
  \ )<CR><C-c>

" Custom buffer mappings
augroup cmdbuf_setting
  autocmd!
  autocmd User CmdbufNew call s:cmdbuf()
augroup END
function! s:cmdbuf() abort
  nnoremap <nowait> <buffer> q <Cmd>quit<CR>
  nnoremap <buffer> dd <Cmd>lua require('cmdbuf').delete()<CR>
endfunction

" open lua command-line window
nnoremap ql <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {type = "lua/cmd"}
  \ )<CR>

" q/, q? alternative
nnoremap q/ <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {type = "vim/search/forward"}
  \ )<CR>
nnoremap q? <Cmd>lua require('cmdbuf').split_open(
  \ vim.o.cmdwinheight,
  \ {type = "vim/search/backward"}
  \ )<CR>
```