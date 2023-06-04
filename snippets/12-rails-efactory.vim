command! -nargs=* -complete=custom,s:CompleteFactories
      \ Efactory call s:Efactory(<q-args>)

function! s:Efactory(factory_name)
  let factory_name = a:factory_name
  let [filename, lineno] = s:FindFactory(factory_name)

  if filename != ''
    exe 'edit ' .. filename
    exe lineno
  else
    echohl WarningMsg | echomsg "Factory not found: ".factory_name | echohl NONE
  endif
endfunction

function! s:FindFactory(name)
  let pattern = '^\s*factory :'.a:name.'\>'

  for filename in s:FindFactoryFiles()
    for [index, line] in items(readfile(filename))
      if line =~ pattern
        return [filename, index + 1]
      endif
    endfor
  endfor

  return ['', -1]
endfunction

function! s:FindFactoryFiles()
  let factory_files = []

  " assume we're in the root of the application
  let root = '.'

  for test_dir in ['test', 'spec']
    call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories.rb'), "\n"))
    call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories/*.rb'), "\n"))
    call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories/**/*.rb'), "\n"))
  endfor

  return factory_files
endfunction

function! s:CompleteFactories(A, L, P)
  let factory_names = []

  for filename in s:FindFactoryFiles()
    for line in readfile(filename)
      let pattern = '^\s*factory :\zs\k\+\ze\s*\%(,\|do\)'

      if line =~ pattern
        call add(factory_names, matchstr(line, pattern))
      endif
    endfor
  endfor

  call sort(factory_names)
  call uniq(factory_names)

  return join(factory_names, "\n")
endfunction
