ruby <<RUBY
if false

  puts "big" if true

  puts "big if true" if true

  puts "big" if true # if false

end
RUBY

nnoremap sj :call Split()<cr>
nnoremap sk :call Join()<cr>

function Split()
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  let pattern = '\S \zsif \S'
  let Skip = {-> synIDattr(synID(line("."), col("."), 0), "name") =~# "String\|Comment" }

  normal! 0
  let [_, if_col] = searchpos(pattern, 'W', line('.'), 0, Skip)
  if if_col == 0
    return
  endif

  let if_line = strpart(getline('.'), if_col - 1)
  let body    = trim(strpart(getline('.'), 0, if_col - 1))
  let indent  = matchstr(getline('.'), '^\s*')

  call setline('.', indent .. if_line)
  call append(line('.'), [indent .. '  ' .. body, indent .. 'end'])
endfunction

function Join()
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  s/if \(.*\)\n\s*\(.*\)\n\s*end$/\2 if \1/e
endfunction
