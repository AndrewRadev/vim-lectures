scriptversion 4

command! -nargs=* -range=0 Grep call s:Grep(<count>, <q-args>)

function! s:Grep(count, query)
  let query = a:query
  let count = a:count

  if count > 0
    let query = s:GetMotion('gv')
  elseif query == ''
    let query = expand('<cword>')
  endif

  exe 'vimgrep /' .. escape(query, '\') .. '/ **/*'
  " exe 'grep ' .. shellescape(query)
endfunction

function s:GetMotion(motion)
  let saved_register = getreg('a')
  defer setreg('a', saved_register)

  exe 'normal! ' .. a:motion .. '"ay'
  return @a
endfunction
