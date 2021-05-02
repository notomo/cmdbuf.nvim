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
