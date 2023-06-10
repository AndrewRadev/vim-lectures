nnoremap X :set operatorfunc=<SID>Encrypt<cr>g@

" Note: doesn't actually encrypt
function! s:Encrypt(motion_type) abort
  if a:motion_type ==# 'line'
    normal! '[V']rX
  elseif a:motion_type ==# 'char'
    normal! `[v`]rX
  elseif a:motion_type ==# 'block'
    throw "Don't know how to handle a block motion"
  else
    throw "Unexpected motion type: "..a:motion_type
  endif
endfunction
