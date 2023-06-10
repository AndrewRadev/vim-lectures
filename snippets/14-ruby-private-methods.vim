if !has('vim9script')
  finish
endif

vim9script

# Define what color the private area will be
hi rubyPrivateMethod cterm=underline gui=underline

# nnoremap _m :call <SID>MarkPrivateArea()<cr>

def MarkPrivateArea()
  # Store the current view, in order to restore it later
  var saved_view = winsaveview()
  defer winrestview(saved_view)

  var start_time = reltime()

  if empty(prop_type_get('private_method', {bufnr: bufnr('%')}))
    prop_type_add('private_method', {
      bufnr:     bufnr('%'),
      highlight: 'rubyPrivateMethod',
      combine:   v:true
    })
  endif

  # Clear out any previous matches
  prop_remove({type: 'private_method', all: v:true})

  # start at the last char in the file and wrap for the
  # first search to find match at start of file
  normal! G$
  var flags = "w"
  var Skip = SkipSyntax('rubyAccess')

  while search('\<private\>', flags, 0, 0, Skip) > 0
    flags = "W"

    var start_line = line('.')
    var end_line = line('.')

    # look for the matching "end"
    var saved_position = getpos('.')
    Skip = SkipSyntax('rubyClass\|rubyModule')

    while search('\<end\>', 'W', 0, 0, Skip) > 0
      end_line = line('.') - 1
      break
    endwhile

    exe ':' .. start_line

    Skip = SkipSyntax('rubyDefine')

    while search('\<def\>', 'W', end_line, 0, Skip) > 0
      prop_add(line('.'), col('.'), {
            \ 'length': 3,
            \ 'type': 'private_method'
            \ })
    endwhile

    # restore where we were before we started looking for the "end"
    setpos('.', saved_position)
  endwhile
enddef

def SkipSyntax(pattern: string): func(): bool
  return () => synIDattr(synID(line("."), col("."), 0), "name") !~# pattern
enddef

augroup rubyPrivateMethod
  autocmd!

  # Initial marking
  autocmd Syntax <buffer> call MarkPrivateArea()

  # Mark on write
  autocmd BufWritePost <buffer> call MarkPrivateArea()

  # Mark when exiting insert mode (doesn't cover normal-mode text changing)
  # autocmd InsertLeave <buffer> call MarkPrivateArea()

  # Mark when text has changed in normal mode. (timeout because sometimes
  # syntax doesn't get updated in time)
  # autocmd TextChanged <buffer> call timer_start(1, (_) => MarkPrivateArea())

  # Mark when not moving the cursor for 'timeoutlen' time
  # autocmd CursorHold <buffer> call MarkPrivateArea()
augroup END

defcompile
