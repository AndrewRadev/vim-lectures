command! ListFactories call s:ListFactories()

function! s:ListFactories()
  vimgrep /^\s*factory :\zs\k\+/j spec/**/*.rb
  copen
endfunction

" function! s:ListFactories() abort
"   let factory_entries = []
"
"   for filename in s:FindFactoryFiles()
"     for [line_index, line] in items(readfile(filename))
"       let pattern = '^\s*factory :\zs\k\+'
"
"       if line =~ pattern
"         let [_match, start_index, _end_index] = matchstrpos(line, pattern)
"
"         call add(factory_entries, #{
"               \   filename: filename,
"               \   lnum:     line_index + 1,
"               \   col:      start_index + 1,
"               \   text:     trim(line),
"               \ })
"       endif
"     endfor
"   endfor
"
"   if len(factory_entries) > 0
"     call setqflist(factory_entries)
"     copen
"   else
"     echomsg "No factories found"
"   endif
" endfunction
"
" function! s:FindFactoryFiles()
"   let factory_files = []
"
"   " assume we're in the root of the application
"   let root = '.'
"
"   for test_dir in ['test', 'spec']
"     call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories.rb'), "\n"))
"     call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories/*.rb'), "\n"))
"     call extend(factory_files, split(glob(root.'/'.test_dir.'/**/factories/**/*.rb'), "\n"))
"   endfor
"
"   return factory_files
" endfunction
