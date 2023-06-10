xnoremap * :call visual_star#Run()<cr>

function! visual_star#Run() range
  " Debug:
  " echomsg "First line: " .. string(a:firstline)
  " trim
  " echomsg "Last line:  " .. string(a:lastline)

  let text = trim(s:GetMotion('gv'))
  let pattern = '\V' .. escape(text, '\')

  call search(pattern)
  let @/ = pattern
endfunction

function s:GetMotion(motion)
  let saved_register = getreg('a')
  defer setreg('a', saved_register)

  exe 'normal! ' .. a:motion .. '"ay'
  return @a
endfunction
