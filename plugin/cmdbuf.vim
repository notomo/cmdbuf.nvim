if exists('g:loaded_cmdbuf')
    finish
endif
let g:loaded_cmdbuf = 1

if get(g:, 'cmdbuf_debug', v:false)
    augroup cmdbuf_dev
        autocmd!
        execute 'autocmd BufWritePost' expand('<sfile>:p:h:h:gs?\?\/?') .. '/*' 'lua require("cmdbuf/lib/cleanup")()'
    augroup END
endif
