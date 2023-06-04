nnoremap <c-w>d :call DeleteWindow()<cr>
nnoremap <c-w>y :call YankWindow()<cr>

nnoremap <silent> <c-w>p :call PasteWindow('rightbelow')<cr>
nnoremap <silent> <c-w>P :call PasteWindow('leftabove')<cr>

function! DeleteWindow()
  call YankWindow()
  quit
endfunction

function! YankWindow()
  call setreg(v:register, expand('%:p'))
endfunction

function! PasteWindow(modifier)
  let path = getreg(v:register)
  if !filereadable(path)
    return
  endif

  execute a:modifier .. ' split ' .. path
endfunction
