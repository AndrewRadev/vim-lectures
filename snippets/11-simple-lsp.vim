command! -buffer SimpleLsp call s:SimpleLsp()

function! s:SimpleLsp() abort
  let cargo_file = findfile('Cargo.toml', '.;')
  if cargo_file == ''
    return
  endif
  let root_path = fnamemodify(cargo_file, ':p:h')
  let root_uri = 'file://' .. root_path

  let job = job_start('rust-analyzer', #{
        \ in_mode: 'lsp',
        \ out_mode: 'lsp',
        \ out_cb: function('s:LspOut'),
        \ err_cb: function('s:LspErr'),
        \ })

  let response = ch_evalexpr(job, #{
        \   method: 'initialize',
        \   params: #{
        \     processId: getpid(),
        \     rootUri: root_uri,
        \     rootPath: root_path,
        \     capabilities: #{
        \       general: #{
        \         positionEncodings: ['utf-8'],
        \       },
        \       textDocument: #{
        \         declaration: #{
        \           dynamicRegistration: v:false,
        \           linkSupport: v:true,
        \         }
        \       },
        \     },
        \   },
        \ })

  " echomsg string(response)
  " PrettyPrint response
  " echomsg string(response['result']['serverInfo'])

  call ch_sendexpr(job, #{
        \   method: 'initialized',
        \   params: #{},
        \ })

  call ch_sendexpr(job, #{
        \   method: 'textDocument/didOpen',
        \   params: #{
        \     textDocument: #{
        \       uri: 'file://' .. expand('%:p'),
        \       languageId: 'rust',
        \       version: b:changedtick,
        \       text: join(getbufline('%', 1, '$'), "\n")
        \     },
        \   },
        \ })

  let response = ch_evalexpr(job, #{
        \   method: 'textDocument/declaration',
        \   params: #{
        \     textDocument: #{
        \       uri: 'file://' .. expand('%:p')
        \     },
        \     position: #{
        \       line: line('.') - 1,
        \       character: col('.') - 1,
        \     },
        \   },
        \ })

  PrettyPrint response
endfunction

function! s:LspOut(_job, message)
  echomsg 'Out: ' .. string(a:message)
endfunction

function! s:LspErr(_job, message)
  echomsg 'Err: ' .. string(a:message)
endfunction
