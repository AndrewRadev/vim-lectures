vim9script

export def Mapping(): void
  b:saved_completefunc = &completefunc
  setlocal completefunc=rustbucket#complete9#CompleteFunc

  autocmd CompleteDone * ++once &completefunc = b:saved_completefunc
  autocmd CompleteDone * ++once unlet b:saved_completefunc

  feedkeys("\<c-x>\<c-u>")
enddef

export def CompleteFunc(findstart: bool, base: string): any
  if findstart
    var [_, start_col] = searchpos('^\s*use \zscrate::[[:keyword:]:]*::', 'bWne', line('.'))

    if start_col <= 1
      return -3 # cancel completion
    else
      return start_col
    endif
  else
    var import = substitute(getline('.'), '^\s*use crate::', '', '')
    var module_path = split(import, '::', 1)

    # remove last part, we're completing it
    var item = remove(module_path, -1)

    var file = 'src/' .. join(module_path, '/') .. '.rs'
    if !filereadable(file)
      file = 'src/' .. join(module_path, '/') .. '/mod.rs'
    endif

    var exports = []
    var export_pattern = '^\s*pub \%(fn\|struct\|trait\|enum\) \zs\k\+'

    for line in readfile(file)
      if line !~ export_pattern
        continue
      endif

      var match = matchstr(line, export_pattern)

      if stridx(match, base) != 0
        continue
      endif

      var taglist = taglist('^' .. match .. '$', file)
      var tag     = taglist->get(0, {})
      var kind    = tag->get('kind', '')

      if kind == 'P'
        continue
      endif

      add(exports, { word: match, menu: trim(line) })
    endfor

    return sort(exports, (a, b) => {
      return (a.word == b.word) ? 0 : a.word > b.word ? 1 : -1
    })
  endif
enddef

defcompile
