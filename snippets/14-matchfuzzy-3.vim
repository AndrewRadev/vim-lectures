vim9script

hi def link fuzzyMatch Search

command! Fuzzy3 call FuzzyFindFile(<q-mods>)

def FuzzyFindFile(mods: string)
  if !executable('rg')
    echoerr "Fuzzy2 requires ripgrep (the `rg` executable)"
    return
  endif

  exe mods .. ' new'
  set buftype=prompt
  setlocal statusline=%{b:statusline}

  b:statusline = ''
  b:all_paths = []
  b:start_time = reltime()
  b:last_update = reltime()
  b:duration = 0
  b:loading = ['⢿', '⣻', '⣽', '⣾', '⣷', '⣯', '⣟', '⡿']
  b:loading_index = 0

  b:job = job_start('slow_rg', {
    out_cb: function('AddPath'),
    exit_cb: function('Finish'),
  })

  prompt_setcallback(bufnr(), function('TextEntered'))
  prompt_setprompt(bufnr(), "> ")
  prop_type_add('score_text', { bufnr: bufnr(), highlight: 'TODO' })

  startinsert

  autocmd TextChangedI <buffer> call UpdateBuffer()
  autocmd QuitPre <buffer> call job_stop(b:job)

  inoremap <buffer> <c-c> <esc>:quit!<cr>
  inoremap <buffer> <c-d> <esc>:quit!<cr>
enddef

def UpdateBuffer()
  if line('$') > 1
    :1,$-1delete _
  endif
  syn clear

  var query = matchstr(getline('.'), '^> \zs.*')
  query = substitute(query, '\s\+', '', 'g')

  if len(query) == 0
    var file_count = min([winheight(0) - 1, len(b:all_paths)])

    for i in range(file_count)
      append(line('$') - 1, b:all_paths[i])
    endfor
  endif

  var results = []
  var [paths, char_positions, scores] =
    matchfuzzypos(b:all_paths, query, { matchseq: 1 })
  var limit = min([winheight(0) - 1, len(paths)])

  for i in range(limit)
    var path = paths[i]
    var score = scores[i]
    var indexes = map(char_positions[i], (_, pos) => byteidx(path, pos))

    append(line('$') - 1, path)
    prop_add(line('$') - 1, 0, {
      type: 'score_text',
      text: score,
      text_padding_left: 1
    })

    for index in indexes
      exe 'syn match fuzzyMatch /\%' .. (line('$') - 1) .. 'l\%' .. (index + 1) .. 'c./'
    endfor
  endfor

  set nomodified
  normal! Gzb
  startinsert!
enddef

def TextEntered(_text: string)
  if line('$') <= 2
    quit
  elseif filereadable(getline(1))
    exe 'edit ' .. getline(1)
  else
    quit
  endif
enddef

def AddPath(_channel: channel, line: string)
  add(b:all_paths, line)

  if reltimefloat(reltime(b:last_update)) > 0.1
    b:statusline = $"Loading {b:loading[b:loading_index]} ({len(b:all_paths)} files)"

    b:loading_index += 1
    b:loading_index %= len(b:loading)

    b:last_update = reltime()
    UpdateBuffer()
  endif
enddef

def Finish(_job: job, status: number)
  if !exists('b:duration')
    return
  endif

  b:duration = reltimefloat(reltime(b:start_time))
  b:statusline = $"Loaded {len(b:all_paths)} files in {b:duration}s"
  UpdateBuffer()
enddef

defcompile
