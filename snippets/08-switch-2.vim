let test_data = ["foo", "bar", "baz"]

let g:test_definitions = {
      \ '"\(\k\+\)"': '''\1''',
      \ '''\(\k\+\)''': '"\1"',
      \ }

nnoremap - :call Switch(g:test_definitions)<cr>

function! Switch(definitions)
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  let cursor_col = col('.')

  for [pattern, replacement] in items(a:definitions)
    let [_, start_col] = searchpos(pattern, 'Wcnb', line('.'))
    if start_col == 0 || start_col > cursor_col
      continue
    endif

    let [_, end_col] = searchpos(pattern, 'Wcne', line('.'))
    if end_col == 0 || end_col < cursor_col
      continue
    endif

    let pattern     = $'\%{start_col}c{pattern}\%{end_col + 1}c'
    let replacement = replacement

    exe 's/'..escape(pattern, '/')..'/'..escape(replacement, '/')
    return
  endfor
endfunction
