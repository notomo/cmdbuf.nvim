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
    nnoremap <buffer> q <Cmd>quit<CR>
endfunction
