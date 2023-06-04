command! -nargs=1 -complete=custom,s:CompleteRailsModels
      \ Emodel call s:Emodel(<q-args>)

" command! -nargs=1 Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  exe 'edit app/models/'.a:model_name.'.rb'
endfunction

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = file
    let name = substitute(name, '^app/models/', '', '')
    let name = substitute(name, '\.rb$', '', '')

    call add(names, name)
  endfor
  return join(names, "\n")
endfunction
