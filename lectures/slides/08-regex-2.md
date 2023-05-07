---
title: Регекси 2
author: Андрей Радев
speaker: Андрей Радев
date: 27 април 2023
lang: bg
keywords: vim,fmi
slide-width: 80%
font-size: 20px
font-family: Cantarell, sans-serif
# code blocks color theme
code-theme: github
---

<style>
code {
    font-size: 100% !important;
    font-variant-ligatures: none;
}
</style>

# Преговор

* Базови регекси
--
* Magic!
--
* Syntax highlighting (без highlighting-а)
--
* `:substitute` и `:global`

---

# Удобен setting за search-ване

* `:help 'shortmess'`
--
* `:set shortmess-=S`
--
* `:set shortmess=acTOI` -- какво имам из моя config (което сигурно съм копирал отнякъде)

---

# Удобен setting за допускане на грешки

* `:help 'undofile'`
* `:help 'undodir'`

---

# Още регекси: lookahead/lookbehind

* `\@!`: Означава, че атома преди него *не* мачва на текущата позиция
--
    * `foo\(bar\)\@!` -- foo, което не е последвано от "bar"
--
* `\@<!`: Означава, че атома преди него *не* мачва *преди* текущата позиция
--
    * `\(foo\)\@<!bar` -- foo, което не е предшествано от "bar"
--
* `\@>`: Означава, че групата преди него трябва да мачне цялата, или изобщо няма да захапе.
--
    * `:\(\k\+\)\@>\(\s*=>\)\@!` -- символ `:keyword`, освен тези, които са последвани от `=>`.
--
    * `:foo` -- match
    * `:bar` -- match
    * `:baz => :bla` -- не, но без `\@>`, ще мачне `:ba`

---

# Още регекси: lookahead/lookbehind

От документацията

```
/\@>    like matching a whole pattern
/\@=    requires a match
/\@!    requires NO match
/\@<=   requires a match behind
/\@<!   requires NO match behind
```

* `\@<=` вероятно не ви трябва, в документацията се препоръчва `\zs`, което би трябвало да прави същото
--
* `\@=` вероятно също не ви трябва:
    * Note that using "\&" works the same as using "\@=": "foo\&.." is the same as "\\(foo\\)\@=..".  But using "\&" is easier, you don't need the parentheses.
--
* Като цяло, тези са бавни и неинтуитивни и обикновено се избягват, но понякога са единствения начин да решим някой проблем (особено негативните такива).

---

# Още регекси: Vim-специфични

* `\%#` -- мачва само на текущата позиция на курсора
--
* `\%V` -- мачва в област, която се намира в последния visual selection
--
* `\%23l` -- мачва на 23-ти ред
* `\%<23l` -- мачва над 23-ти ред
* `\%>23l` -- мачва под 23-ти ред
--
* `\%23c` -- мачва на 23-та колона
* `\%<23c` -- мачва преди 23-та колона
* `\%>23c` -- мачва след 23-та колона
--
* `\%23v` -- мачва на 23-та виртуална колона
* `\%<23v` -- мачва преди 23-та виртуална колона
* `\%>23v` -- мачва след 23-та виртуална колона
--
* Екзотични и доста ситуационни

---

# Highlighting

Просто връзваме filetype-специфичните групи с "глобалните":

```vim
highlight link javaScriptComment Comment
" За кратко:
hi link javaScriptComment Comment
" Ако някой реши да линкне *преди* това:
hi default link javaScriptComment Comment
```

Списък на всички стандартни групи, които не са filetype-specific: `:help highlight-groups`. Стандартните конвенции като "Comment", "String" etc се гледат от някоя цветова схема.

---

# Highlighting: GUI

Цветовите схеми highlight-ват generic групите:

```vim
highlight {група} gui=<bold,italic,etc> guifg=#<color> guibg=#<color> guisp=#<color>

hi Search guifg=#e4e4e4 guibg=#6a0dad gui=NONE
hi SpellBad guifg=#ff0000 guibg=NONE guisp=#ff0000 gui=undercurl cterm=underline
hi SpellCap guifg=#00d700 guibg=NONE guisp=#00d700 gui=undercurl cterm=underline
```

* За детайли: `:help highlight-gui`
* За помощ: <https://github.com/lilydjwg/colorizer> (има и други подобни)

---

# Highlighting: Terminal

```vim
highlight {група} ctermfg=<число> ctermbg=<число> cterm=<ефект>

hi Search ctermfg=254 ctermbg=55 cterm=NONE
hi IncSearch ctermfg=29 ctermbg=NONE cterm=reverse
```

* Или може да сложите `:set termguicolors` и да ползвате gui highlighting-а. Днешно време обикновено това се прави.
* За помощ: <https://github.com/guns/xterm-color-table.vim>

---

# Highlighting

Командата `highlight` може да се извиква колкото пъти си искате с каквато и да е комбинация от gui, cterm, term параметри, примерно и двата начина работят:

```vim
hi Comment ctermfg=248
hi Comment guifg=#777777

hi Comment ctermfg=248 guifg=#777777
```

Също така може просто да викнете `:highlight` или `:highlght <група>` за информация

---

# Highlighting

* Искате да link-нете различни цветове или да използвате различен syntax файл? Направете си `syntax/<filetype>.vim` и накрая сложете `let b:current_syntax = '<filetype>'`
    * `:help syntax-loading`
--
* Или ако си инсталирате plugin с filetype support, той ще направи точно това, примерно: <https://github.com/pangloss/vim-javascript>
--
* Ако просто искате да добавите неща, може да ползвате `after/syntax/<filetype>.vim`
    * Удобно за вложени неща: https://github.com/inkarkat/vim-SyntaxRange
    * [Примерна употреба за ruby heredocs](https://github.com/AndrewRadev/Vimfiles/blob/f00133921a3fab6408e39e196a143b0ea9a12cb5/after/syntax/ruby.vim)
--
* Аутокоманди:
    * `autocmd Syntax <filetype> ...`
    * `autocmd ColorSchemePre <име на схемата> ...`
    * `autocmd ColorScheme <име на схемата> ...`

---

# Fun: TOhtml

* `:TOhtml` е команда, която конвертира текущия прозорец (или селектираните редове) в еквивалентния HTML. No joke
--
* `:help convert-to-html`
    * `let g:html_line_ids = 1`
    * `let g:html_dynamic_folds = 1`
--
* И после копи-пейст в libreoffice: <https://andrewra.dev/2019/10/05/from-vim-to-presentation-slides/>

---

# Естетиката е важна

Откъде да намерим цветове?

* `$VIMRUNTIME/colors` съдържа всички вградени
--
* <https://github.com/vim/colorschemes> съдържа подобрени вградени, които целят да бъдат вкарани в главното repo.
--
    * Това е стандартен подход за filetypes -- примерно <https://github.com/vim-ruby/vim-ruby> си се движи и от време на време се вкарва в главните файлове.
    * Примерно, скорошни добавки: <https://www.reddit.com/r/vim/comments/12z4284/new_builtin_colorschemes/>
--
* Google/DuckDuckGo "vim colorschemes":
    * https://github.com/flazz/vim-colorschemes -- скрейпнати от vim.org
    * https://vimcolorschemes.com/ -- джиджав сайт с preview-та
    * https://github.com/rafi/awesome-vim-colorschemes -- с още линкове
--
* Препоръка: харесайте си нещо, направете си копие и го тунинговайте

---

# Spellcheck

* Първа стъпка: изтегляме си `bg.utf8.spl` и `bg.utf8.sug` от този супер готин сайт: <https://ftp.nluug.nl/pub/vim/runtime/spell/>
    * (Или разчитаме на Vim да ни ги предложи в трета стъпка)
--
* Втора стъпка: слагаме файловете в `~/.vim/spell/`
--
* Трета стъпка: `set spell spelllang=bg,en` (примерно)
--
* ???
* Profit

---

# Spellcheck

* `z=` -- показва опции за поправяне на думата под курсора
* `zg` -- маркира думата като валидна (и я добавя във `~/.vim/spell/<lang>.utf-8.add`)
* `]s`, `[s` -- търсят грешни думи напред или назад
* И тонове други, във `:help spell`

---

# Substitute()

Обратно на регексите

--

```vim
let string = "Hello, World!"
let string = substitute(string, '\k\+\ze!', 'Vim', 'g')
```

---

# Substitute()

`:help substitute()` (скобките са важни, иначе help-а ще отвори `:substitute`)

* `substitute({string}, {pat}, {sub}, {flags})`
--
* Флаговете -- или `g` (замести всички срещания) или нищо
--
* Работи като `:substitute`, но с хвърчащи низове, не в буфера. Съответно, `\%#` и подобни нямат смисъл.
--
* Fun: може `{sub}` да е функция, която приема списък от целия match и submatch-овете
    * същите данни, които идват от `matchlist()` на следващия слайд

---

# Match*()

* `match({expr}, {pat} [, {start} [, {count}]])` -- връща позицията на match-а
    * `match("testing", "ing") == 4`
    * `match([1, 'x'], '\a') == 1`
--
* `matchlist({expr}, {pat} [, {start} [, {count}]])`

```vim
echo matchlist("  big if true", '\(\S.*\) if \(.*\)')
" ['big if true', 'big', 'true', '', '', '', '', '', '', '']
```
```vim
let [match, body, condition; rest] = matchlist(" big if true", '\(\S.*\) if \(.*\)')
```

---

# Matchstr()

* `matchstr({expr}, {pat} [, {start} [, {count}]])`

```vim
echo matchstr("  big if true", '\(\S.*\) if \(.*\)')
" big if true

echo matchstr("  big if true", '\zs\S.*\ze if .*')
" big
```

---

# Matchstrpos()

* `matchstrpos({expr}, {pat} [, {start} [, {count}]])`

```vim
let [word1, start1, end1] = matchstrpos("One word, then another", '\w\+')
let [word2, start2, end2] = matchstrpos("One word, then another", '\w\+', end1)
let [word3, start3, end3] = matchstrpos("One word, then another", '\w\+', end2)

echo string([word1, word2, word3])
" ['One', 'word', 'then']
```

Напомням, че има `:help string-functions`

---

# Search*()

Доста важна фамилия от функции. Работят върху буфера, не върху низове.

* `search({pattern} [, {flags} [, {stopline} [, {timeout} [, {skip}]]]])`
--
    * Pattern: регекс. Само `call search('foobar')` ще работи все едно сме извикали `/foobar`
    --
    * Само че няма нужда да escape-ваме delimiter: `call search('https://')` си работи супер
    --
    * Премества курсора на регекса, връща реда, на който е match-нал. Ако не проработи, курсора не се премества, резултата е 0. Така че `if search(...)` работи

---

# Search()

Флагове -- комбинират се в един низ

--
* 'w' -- wrap, след последния match започва от началото на буфера (default)
* 'W' -- nowrap, след последния match в буфера, спира
--
* 'b' -- търси за match назад, а не напред както по default
--
* 'e' -- премества се в *края* на match-а, а не в началото
--
* 'c' -- приема match на текущата позиция на курсора. Защо не по default? За да може следващото извикване да се премести, иначе ще си седи на едно място
--
* 'n' -- изобщо не премества курсора, само връща резултат. По-полезно със `searchpos`.

Има и други флагове, но тези са най-често използвани. Пример: `search('https://', 'Wbc')` ще потърси за линк някъде преди курсора, но ще го приеме и на текущата позиция. Няма да wrap-не ако не намери нищо.

---

# Search()

* Stopline параметъра позволява да кажем "не търси отвъд този ред". Често се ползва `line('.')`, което е текущия ред, примерно `call search('https://', 'bc', line('.'))` ще търси URL назад, но само на текущия ред.
--
* Timeout параметъра е в случай на по-сложен регекс и огромен файл, ако имаме потенциален риск да отнеме твърде много време. Рядко се използва, но когато си трябва, си трябва.
--
* Skip параметъра е мега важен за някои цели. Когато се match-не нещо, се eval-ва като expression, и ако върне истина, този match се скипва и се минава на следващия. Пример -- след малко.

---

# Searchpair()

`searchpair({start}, {middle}, {end} [, {flags} [, {skip} [, {stopline} [, {timeout}]]]])`

```vim
call searchpair('\<if\>', '\<else\>', '\<endif\>')
```

Скача по първия, втория, третия регекс, и игнорира вложени match-ове!

```vim
if outer_branch
  echomsg "Yes"
else
  echomsg "No"

  if inner_branch
    echomsg "Maybe"
  else
    echomsg "I don't know"
  endif
endif
```

---

# Searchpair()

Вървене на обратно с `'b'` работи, но е малко странно.

```
The search starts exactly at the cursor.  A match with
{start}, {middle} or {end} at the next character, in the
direction of searching, is the first one found.

[...]

When searching backwards and {end} is more than one character,
it may be useful to put "\zs" at the end of the pattern, so
that when the cursor is inside a match with the end it finds
the matching start.
```

Т.е. за горния пример, ако вървим на обратно, вероятно искаме:

```vim
call searchpair('\<if\>', '\<else\>\zs', '\<endif\>\zs', 'b')
```

(В повечето случаи ще търсим неща напред, so whatever)

---

# Aside: matchit

Сложете си това във vimrc-тата и ще имате по-мощен `%`:

```vim
packadd matchit
```

---

# Search*()

* `searchpos` -- същото като `search`, но връща `[lnum, col]` като резултат
* `searchpairpos` -- същото като `searchpair`, но връща `[lnum, col]` като резултат

---

# Switch клонинг

Сменяме единични на двойни кавички под курсора. Опростен вариант на [switch.vim](https://github.com/AndrewRadev/switch.vim)

```vim
let test_data = ["foo", "bar", "baz"]

let g:test_definitions = {
      \ '"\(\k\+\)"': '''\1''',
      \ '''\(\k\+\)''': '"\1"',
      \ }

nnoremap - :call Switch(g:test_definitions)<cr>

function! Switch(definitions)
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  " ...
endfunction
```

---

# Switch клонинг

Един вариант -- намираме pattern-а и добавяме `\%#` за да се погрижим да се изпълни точно където сме match-нали.

```vim
function! Switch(definitions)
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  for [pattern, replacement] in items(a:definitions)
    if search(pattern, 'Wcb')
      exe 's/\%#'..escape(pattern, '/')..'/'..escape(replacement, '/').'/'
    endif
  endfor
endfunction
```

---

# Switch клонинг

Втори вариант, без да местим курсора -- вземаме координатите и ги прикачваме към pattern-a със `\%c`

```vim
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
```

---

# Splitjoin клонинг

Трансформираме if-клаузи от `body if condition` на `if condition \n body \n end`. Join-ването може да е толкова лесно (стига да можете да прочетете регекса :D)

```vim
function Join()
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  s/if \(.*\)\n\s*\(.*\)\n\s*end$/\2 if \1/e
endfunction
```

(`e` флага -- да не хвърли грешка ако не match-не)

---

# Splitjoin клонинг

Сплитването също спокойно може да е един substitution. Но ако искаме да избягваме if-ове в низове и коментари...

```vim
function Split()
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  let pattern = '\S \zsif \S'
  let skip = 'synID(line("."), col("."), 0)->synIDattr("name") =~# "String\|Comment"'

  normal! 0
  let [_, if_col] = searchpos(pattern, 'W', line('.'), 0, skip)
  if if_col == 0
    return
  endif

  let if_line = getline('.')->strpart(if_col - 1)
  let body    = getline('.')->strpart(0, if_col - 1)->trim()
  let indent  = getline('.')->matchstr('^\s*')

  call setline('.', indent .. if_line)
  call append(line('.'), [indent .. '  ' .. body, indent .. 'end'])
endfunction
```

---

# Splitjoin клонинг

Без `foo()->bar()` синтаксиса (можете ли да напишете vimscript, който да прави тази трансформация, switch-style?) и със ламбда функция за skip expression-а вместо eval-нат низ.

```vim
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
```

(Забележете, че `skip` вече е `Skip`. Функциите трябва да започват с главна буква :))

---

# Splitjoin

Пълния плъгин е *доста* по-голям: <https://github.com/andrewradev/splitjoin.vim>

Но индивидуалните функции решават конкретни малки проблеми. Стъпка по стъпка можете за проекта да си направите такъв плъгин, който просто има 3-4 полезни трансформации за 3-4 различни filetype-а, стига да измислите общата "схема", какво концептуално прави.
