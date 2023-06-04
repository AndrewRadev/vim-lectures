let test_data = ["foo", 'bar', "baz"]

let g:test_definitions = {
      \ '"\(\k\+\)"': '''\1''',
      \ '''\(\k\+\)''': '"\1"',
      \ }

nnoremap - :call Switch(g:test_definitions)<cr>

function! Switch(definitions)
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  for [pattern, replacement] in items(a:definitions)
    if search(pattern, 'Wcb')
      exe 's/\%#'..escape(pattern, '/')..'/'..escape(replacement, '/').'/'
    endif
  endfor
endfunction
