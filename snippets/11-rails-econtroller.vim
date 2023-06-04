command! -nargs=1 -complete=custom,s:CompleteRailsControllers
      \ Econtroller call s:Econtroller(<q-args>)

function! s:Econtroller(model_name)
  exe 'edit app/controllers/'.a:model_name.'_controller.rb'
endfunction

function! s:CompleteRailsControllers(A, L, P)
  let names = []
  for file in split(glob('app/controllers/**/*_controller.rb'), "\n")
    let name = file
    let name = substitute(name, '^app/controllers/', '', '')
    let name = substitute(name, '_controller\.rb$', '', '')

    call add(names, name)
  endfor
  return join(names, "\n")
endfunction
