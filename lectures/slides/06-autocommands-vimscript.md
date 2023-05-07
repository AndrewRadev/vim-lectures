---
title: Аутокоманди, vimscript
author: Андрей Радев
speaker: Андрей Радев
date: 6 април 2023
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

# Административни неща

* 13ти-18ти април: Великден
* Без упражнения тези дни, без лекция на 13ти

---

# Преговор

* Базова употреба на git: commit, push/pull, log/diff, submodules
--
* Vim плъгини по лесния начин: vim-plug
--
* Vim плъгини по трудните начини: submodules, packages

---

# Малко конфигурация на плъгини

* `:help NERDTree` -- доста за четене
* `:help smartword` -- с override-ването на дефолтни мапинги трябва да се внимава, но...

---

# Довършване на defaults.vim

Безинтересни за мен, но какво значат?

* `:help gq`, `:help Ex-mode`
* `:help i_CTRL-U`, `:help i_CTRL-G_u`

--

Kind of интересно:

* `DiffOrig`

---

# Aside: разбиване на редове

Backslash на следващия ред означава, че се комбинира с предния ред. Да, странно е.

```vim
command! -nargs=* -range=0 Grep call grep#Run(<count>, <q-args>)

command! -nargs=* -range=0
      \ Grep call grep#Run(<count>, <q-args>)

command! -nargs=* -range=0 Grep
      \ call grep#Run(<count>, <q-args>)
```

---

# Довършване на defaults.vim

Аутокоманди!

* Скачане на последната редактирана позиция
* Anti-confusion hint

---

# Autocmd, augroup

```vim
augroup MyCustomName
  autocmd!

  autocmd <event> <pattern> <command>
augroup END
```

Функциите и командите имат име, затова имаме `function! <name>` и `command! <name>`. Индивидуални аутокоманди няма как да се зачистват без именувана група.

Pattern (обикновено) описва файла, който е trigger-нал аутокомандата, често няма значение и ще бъде `*`, което е "каквото и да е". `:help autocmd-patterns`, но сигурно ще ги говорим по-натам.

---

# Примери: Undoquit

```vim
autocmd QuitPre * call undoquit#SaveWindowQuitHistory()
```

---

# Примери: Typewriter

```vim
augroup Typewriter
  autocmd!
  autocmd TextChangedI,TextChangedP * call s:Click()
  autocmd InsertEnter * call sound_playfile(s:carriage)
  autocmd InsertLeave * call sound_playfile(s:ding)
augroup END
```

---

# Примери: Sarcasm mode

"THis iS A Very uSEFul PLUgin"

```vim
autocmd InsertCharPre * if rand() % 2 | let v:char = toupper(v:char) | endif
```

---

# Примери: "Редактиране" на mp3ки

```vim
autocmd BufReadCmd *.mp3  call id3#ReadMp3(expand('<afile>'))
autocmd BufWriteCmd *.mp3 call id3#UpdateMp3(expand('<afile>'))
```

---

# Autocmd

Пълен списък: `:help autocmd-events`

---

# Autocmd: дебъгване

* `:help autocmd-define`
--
* `:set verbose=9`, но бъдете готови за много output
--
* `:set verbosefile=some_file_path.txt` -- редиректва целия output във файл, но пак е много
--
* `autocmd CursorMoved`

---

# Filetypes

Ако искаме да променяме настройки за специфични типове файлове? Един вариант:

```vim
autocmd FileType ruby   set expandtab   shiftwidth=2 softtabstop=2
autocmd FileType python set expandtab   shiftwidth=4 softtabstop=4
autocmd FileType go     set noexpandtab shiftwidth=4 tabstop=4
```

---

# Ftplugin

Друг (по-чест) вариант:

* `~/.vim/ftplugin/ruby.vim`
* `~/.vim/ftplugin/python.vim`
* `~/.vim/ftplugin/go.vim`

---

# Ftplugin

* Може да е добра идея да ползвате `setlocal` (`:help local-options`), но рядко е задължително. Просто никога не е грешно.
--
* Локални мапинги: `map <buffer>`
* Локални команди: `command! -buffer`
* Локални променливи: `let b:some_value = ...`

---

# Ftplugin

* Зареждат се:
    * `ftplugin/<filetype>.vim`
    * `ftplugin/<filetype>_<каквото и да е>.vim`
    * `ftplugin/<filetype>/<каквото и да е>.vim`
--
* Примерно:
    * `ftplugin/ruby.vim`
    * `ftplugin/ruby_settings.vim`
    * `ftplugin/ruby/commands.vim`

---

# Statusline: за да виждаме filetype-а

`:help statusline`

* Тонове опции, само ще добавим filetype и ще ги оставим за после
--
* Default:
    * `set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P`
* Малко тунингован (`s/%h/%y`):
    * `set statusline=%<%f\ %y%m%r%=%-14.(%l,%c%V%)\ %P`
--
* Повече customization -- по-нататък.
    * Примерно: `set statusline=Here\ is\ the\ time:%=%{CurrentTime()}%=Amazing,\ right\ 🤯`
    * Някои хора overengineer-ват statusline-а до космически нива

---

# Ftplugin: Базов detection

Директорията "ftdetect" съдържа файлове, които се оценяват с цел detection (`:help ftdetect`)

```vim
" ~/.vim/ftdetect/notes.vim
autocmd BufNewFile,BufRead *.notes set filetype=notes
```

---

# Ftplugin: Dot notation

Можем да си направим "комбиниран" тип:

```vim
" ~/.vim/ftdetect/rspec.vim
autocmd BufNewFile,BufRead *_spec.rb set filetype=rspec.ruby
```

Това ще изпълни ftplugin скриптовете и на "rspec" типа, и на "ruby" типа ("dot notation")

---

# Ftplugin: setfiletype

```vim
" ~/.vim/after/ftdetect/txt.vim
autocmd BufNewFile,BufRead * setfiletype txt
```

Fallback -- `setfiletype` е "set-ни filetype, ако не е бил set-нат преди"

---

# Vimscript в повече детайли

* `:help expression` -- пълния reference към Vimscript-ските изрази
* `:help function-list` -- пълен списък на *всички* функции
--
* Редовете се парсят един по един
* Всеки ред е команда
    * не `foo = "bar"`, а `let foo = "bar"`
    * не `function_call()`, а `call function_call()` или `echo function_call()` или `let x = function_call()`
--
* Събиране на редове: `|` между команди, `let a = 1 | let b = 2`
* Разбиване на редове: `\` в началото

---

# Vimscript: числа

* `Number`: `-123`, `0x10`, `0o177`, `0b1011`
* `Float`: `123.456`, `1.15e-6`, `-1.1e3`
--
* `string(3.14)` -> `"3.14"`
--
* `str2nr("3.14")` -> `3`
* `str2float("3.14")` -> `3.14`
* `str2float("foobar")` -> `0`
--
* Оператори: `+ - * / % << >>`
* (И унарен `+ -`)

---

# Vimscript: Низове

* Двойни кавички: `"Баба Яга"`
* С ескейпване:

```vim
echo "Баба\n\"Яга\"\\n"
```
```
Баба
"Яга"\n
```

* Всички специални ескейп кодове: `:help expr-quote`

---

# Vimscript: Низове

* Единични кавички: `'Бабата на Яга'` (`:help literal-string`)
* Всичко е литерално, включително `\`', единични кавички се удвояват, за да се използват:

```vim
echo 'Yaga''s grandma\n'
```
```
Yaga's grandma\n
```

---

# Vimscript: Низове

* Интерполация -- доларче с двойни или единични кавички (`:help interpolated-string`)
    * Ново: `v9.0.0934`

```vim
let who = 'Yaga'
echo $"{who}'s grandma"
echo $'Grandma {who}'
```
```
Yaga's grandma
Grandma Yaga
```

---

# Vimscript: Низове

`:help string-functions`

--
* `strlen()`, `strcharlen()`
* `strwidth()`, `strdisplaywidth()`
--
* `strpart()`, `strcharpart()`
--
* `trim()`, `repeat()`
--
* И една купчина неща с регекси, които оставяме за по-нататък
* `:help repeat(` или каквато и да е функция за детайли

---

# Vimscript: Булеви стойности

* Лъжа: `0`
* Истина: `1` или каквото и да е ненулево число
--
* `||`, `&&`, `!`
* `!8` -> `0`, `!!8` -> `1`
--
* `1 > 2` -- лъжа
* `4 >= 3` -- истина
* и т.н.

---

# Vimscript: If-ове

```vim
if 2 + 2 == 4 && 2 > 1
  echo "Right, that all makes sense"
elseif 2 <= 1
  echo "No, no, that's incorrect"
else
  echo "Now this is completely unexpected"
endif
```

--
Има и тернарен оператор: `2 > 1 ? "ok" : "not okay"`
--
Има и "falsy" оператор: `search(...) ?? line('.')` (`v8.2.1831`)

---

# Vimscript: Сравнения (уф)

--
* `1 == "1"` -- истина :)
--
* `1 is 1` -- истина,
* `1 is "1"` -- лъжа...
--
* но това е "идентичност", не равенство -- `[] is []` е лъжа, защото са различни обекти в паметта. Така че е полезно горе-долу само за числа
--
* (Във vim9script, типовете на две стойности трябва да match-ват за да се сравняват)
--
* (ако не сте гледали WAT, гледайте: https://www.destroyallsoftware.com/talks/wat)

---

# Vimscript: Сравнения (уфффф)

--
* `"abc" == "abc"` -- истина, но...
--
* `"abc" == "ABC"`?
--
* Зависи дали имаме `:set ignorecase` 🙃

---

# Vimscript: но защо???

--
* Представете си, че search-ваме за `/Foo` (или доста по-сложен регекс) и намерим резултат. Ако сега вземем този регекс и го ползваме някъде като `getline('.') =~ 'Foo'`... Ще работи ли?
--
* Ако кажем "регексите трябва да работят консистентно", защо `=~`, а не `==`?
--
* Неочевиден проблем е, който други езици нямат нужда да решават, защото нямат "editor UI"

---

# Vimscript: решения?

* `1 == "1"`? Просто не правете грешки, problem solved
--
* За числа, `1 is 1`, `2 isnot 3` ще сработи
--
* `==#` винаги е case-sensitive
* `==?` винаги е case-insensitive
* `==` зависи от конфигурацията (и съответно е подходящо за лични скриптове)
--
* moving on...

---

# Vimscript: Списъци

* Квадратни скобки: `[1, 2, 3]`
* Индексиране `some_list[3]`
* `let some_list = [1, 2, 3]`
* `let some_list[1] = 4`
* `let some_list[-1] = 8` -- последния елемент
--
* `let some_list[10] = 5` -- грешка!
* `echo some_list[20]` -- грешка!

---

# Vimscript: Slice-ване

`:help sublist`

```vim
let some_list = [1, 2, 3, 4]

let endlist   = some_list[2:]  " от третия елемент нататък: [3, 4]
let shortlist = some_list[2:2] " само третия елемент [3]
let otherlist = some_list[:]   " копие на списъка
let startlist = some_list[:-2] " без последния елемент: [1, 2, 3]
```

Ако втория индекс е твърде голям, просто се взема списъка до края
--
Fun fact: тези работят и за низове, но работят по байтове, което може да е рисковано.

---

# Vimscript: Сравнение на списъци

* `let a = [] | let b = []      | echo a isnot b` -- различни списъци
* `let a = [] | let b = a       | echo a is b` -- един и същи списък
* `let a = [] | let b = copy(a) | echo a isnot b` -- различни списъци

---

# Vimscript: Unpack-ване на списъци

```vim
let some_list = ['foo', 'bar', 'baz']

let [f, br, bz] = some_list
let [f; rest]   = some_list
```

---

# Vimscript: Промяна на списъци

`:help list-modification`

* `call add(list, "new_item")` -- добавя елемент накрая
* `call extend(list, [1, 2])` -- добавя друг списък накрая
--
* `let value = remove(list, 3)` -- маха стойността, връща я
--
* `call sort(list)`
* `call reverse(list)`
* `call uniq(sort(list))`
--
* Всички операции са на място (мутират списъка)!
* Всички операции *освен това* връщат (reference към) списъка. Т.е. `let l = sort(l)` ще работи, но също и само `call sort(l)`
* `let sorted_l = sort(copy(l))`

---

# Vimscript: Итериране на списъци

```vim
for item in [1, 2, 3]
  echo "Ей го на: " .. item
endfor
" Ей го на: 1
" Ей го на: 2
" Ей го на: 3
```

---

# Vimscript: Итериране на списъци

```vim
for item in range(1, 3)
  echo "Ей го на: " .. item
endfor
" Ей го на: 1
" Ей го на: 2
" Ей го на: 3
```

`:help range(`

---

# Vimscript: Итериране на списъци

```vim
for [index, item] in [[0, "foo"], [1, "bar"], [2, "baz"]]
  echo index .. ") Ей го на: " .. item
endfor
" 0) Ей го на: foo
" 1) Ей го на: bar
" 2) Ей го на: baz
```

---

# Vimscript: Речници

`:help Dict`

--

```vim
let stuff = { 'foo': 1, 'bar': 2, 'baz': 3 }

let stuff = {
      \ 'foo': 1,
      \ 'bar': 2,
      \ 'baz': 3,
      \ }
```

--

Важно! Ключа *винаги* е низ:

```vim
let stuff = { 1: 'foo', 3.14: 'bar' }
echomsg string(stuff)
" {'1': 'foo', '3.14': 'bar'}
```

---

# Vimscript: Речници

Ключа също така е "expression":

```vim
let f = "foo"
let stuff = { f: 1, 'bar': 2, 'baz': 3 }
```

--

Ако искаме низове без кавички, може да използваме `#{`

```vim
let stuff = #{ foo: 1, bar: 2, baz: 3 }

let stuff = #{
      \ foo: 1,
      \ bar: 2,
      \ baz: 3,
      \ }
```

---

# Vimscript: Речници

Четене и писане:

```vim
let value = stuff['foo']
let value = stuff.bar

let stuff['foo'] = 100
let stuff.bar = 200
```

---

# Vimscript: Итериране на речници

```vim
let stuff = { 'foo': 1, 'bar': 2, 'baz': 3 }

for key in keys(stuff)
  echo "Ей ти ключове: " .. key
endfor
" Ей ти ключове: foo
" Ей ти ключове: baz
" Ей ти ключове: bar
```

---

# Vimscript: Итериране на речници

```vim
let stuff = { 'foo': 1, 'bar': 2, 'baz': 3 }

for value in values(stuff)
  echo "Ей ти стойности: " .. value
endfor
" Ей ти стойности: 1
" Ей ти стойности: 3
" Ей ти стойности: 2
```

---

# Vimscript: Итериране на речници

```vim
let stuff = { 'foo': 1, 'bar': 2, 'baz': 3 }

for [key, value] in items(stuff)
  echo $"Ей ти ключове и стойности: {key}, {value}"
endfor
" Ей ти ключове и стойности: foo, 1
" Ей ти ключове и стойности: baz, 3
" Ей ти ключове и стойности: bar, 2
```

---

# Vimscript: Функции за речници

* `has_key(stuff, 'foo')` -- доста важно, защото непознати ключове ще гръмнат
* `get(stuff, 'foo', 'default_value')`
--
* Впрочем, `get([1, 2, 3], 10, 'default_value')` -- също работи

---

# Vimscript: Функции

```vim
function! Add(left, right)
  return a:left + a:right
endfunction

echo Add(2, 3)
" => 5
```

---

# Vimscript: Функции

```vim
function! Add(...)
  echo $"Брой на аргументите:       {a:0}"
  echo $"Първи аргумент:            {a:1}"
  echo $"Втори аргумент:            {a:2}"
  echo $"Всички аргументи в списък: {string(a:000)}"

  let sum = 0

  for input in a:000
    let sum += input
  endfor

  return sum
endfunction

echo Add(2, 3, 5, 8, 7)
" Брой на аргументите:       5
" Първи аргумент:            2
" Втори аргумент:            3
" Всички аргументи в списък: [2, 3, 5, 8, 7]
" 25
```

---

# Vimscript: Функции

```vim
function! Add(...)
  echo $"Брой на аргументите:       {a:0}"
  echo $"Първи аргумент:            {a:1}"
  echo $"Втори аргумент:            {a:2}"
  echo $"Всички аргументи в списък: {string(a:000)}"

  " За ентусиастите, но за това по-нататък
  return reduce(a:000, { acc, val -> acc + val }, 0)
endfunction

echo Add(2, 3, 5, 8, 7)
" Брой на аргументите:       5
" Първи аргумент:            2
" Втори аргумент:            3
" Всички аргументи в списък: [2, 3, 5, 8, 7]
" 25
```

---

# Vimscript: Извикване на функции

```vim
call Add(1, 2)
call call('Add', [1, 2])
```

--

```vim
let Plus = function('Add')
call Plus(1, 2)
call call(Plus, [1, 2])
```

--

```vim
echomsg string(Plus)
" function('Add')
```

---

# Vimscript: Извикване на функции

ама едно такова като ООП, kind of

```vim
echo 1->Add(2)
" call 1->Add(2) -- не работи

echo uniq(sort(add([2, 1, 1, 4], 3)))
echo [2, 1, 1, 4]->add(3)->sort()->uniq()
" [1, 2, 3, 4]
" [1, 2, 3, 4]
```

Повече "ООП, kind of", по-нататък

---

# Vimscript: Засега толкоз

--

Има още много, но това би трябвало да ви стигне, за да:

* Разгледате сорса на Undoquit: <https://github.com/AndrewRadev/undoquit.vim>
--
* Решите някои простички упражнения в Exercism: <https://exercism.org/tracks/vimscript/exercises>
