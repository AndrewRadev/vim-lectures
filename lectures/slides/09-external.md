---
title: Интегриране с външни програми
author: Андрей Радев
speaker: Андрей Радев
date: 4 май 2023
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

* Project guide: <https://vim-fmi.bg/guides/projects>
    * Няма нужда да бързате, ще говорим още за проектите и ще има още идеи

---

# Преговор

* По-екзотични регекси
--
* Цветове и шаренийки
--
* `:TOhtml`
--
* Spellchecking
--
* Низови функции с регекси: `matchstr`, `substitute`
--
* `search`-фамилията от функции

---

# Input

```vim
let answer = input("How do you feel today? ")
redraw

if answer =~? 'good\|okay\|alright'
  echomsg "Cool."
else
  echomsg "Yeah whatever"
endif
```

---

# Input: допълнителни параметри

* Дефолтна стойност
* Completion (`:help command-completion`)

```vim
let new_name = input("Rename file: ", expand('%'), 'file')
redraw
echomsg $"Preview: call rename('{expand('%')}', '{new_name}')"
```

---

# Input: варианти

```vim
let answer = inputlist([
      \   "Коя от тези функции работи върху буфера?",
      \   "1) matchstr()",
      \   "2) searchpairpos()",
      \   "3) substitute()",
      \ ])
redraw

if answer == 2
  call sound_playevent('dialog-information')
  echohl String | echomsg "✅" | echohl None
else
  call sound_playevent('dialog-warning')
  echohl ErrorMsg | echomsg "❌" | echohl None
endif
```

---

# Input: пароли

```vim
let cc = inputsecret("Enter your credit card, don't worry about it")
```

Странично: Vim може да криптира файлове:

* `:help encryption`
* `:help :X`
* `:help 'cryptmethod'`

---

# Confirm: Y/N?

```vim
if confirm("Download spell file?", "&Yes\n&No", 2) == 1
  echomsg "No."
endif
```

---

# Redir

Малко хакаво, ама не е за сефте:

```vim
redir => output
  silent digraphs
redir END

let umlaut_digraph = matchstr(output, '..\ze ü')
redraw
echomsg "Digraph for ü is: '" .. umlaut_digraph .. "'"
```

* `redir => <var>` ще създаде променлива с това име и ще напълни output-а в нея.
--
* `silent` командата спира output-а на вътрешната команда, но *не* за redir. Без `silent`, би напечатало output-а освен да го сложи в `output`.
--
* Дребна досада: `silent!` преди команда скрива грешки, но те пак се появяват в output-а на `redir`

---

# Redir

Има варианти за файл и за регистри

* `:redi[r][!] > {file}` -- записва файл
* `:redi[r][!] >> {file}` -- append-ва във файл
* `:redi[r] @{a-zA-Z*+"}>` -- във регистър
* `:redi[r] => {var}` -- append-ва в променлива

---

# Вместо redir: execute()

Днешно време има по-удобен вариант, `:help execute()`:

```vim
let output = execute('digraphs', 'silent')

let umlaut_digraph = matchstr(output, '..\ze ü')
redraw
echomsg "Digraph for ü is: '" .. umlaut_digraph .. "'"
```

* Този път, може да подадем и `silent!` и ще глътне грешките.
--
* Може да се викне с няколко поредни команди в списък: `execute([cmd1, cmd2])`
--
* Впрочем, `digraph_getlist(v:true)` ще ни даде всички digraphs по доста по-прост начин. Вижте `:help digraph_get(` и скролнете надолу.

---

# Lambda функции

`:help lambda`

Можем да си дефинираме "анонимна функция" или "ламбда". Тези двете са горе-долу еквивалентни:

```vim
function Add1(x, y)
  return a:x + a:y
endfunction

let Add2 = { x, y -> x + y }

echomsg Add1(3, 4)
echomsg Add2(3, 4)
" 7
" 7
```

Ламбда функция с един аргумент е `{ input -> ... }`, с нула е `{ -> ... }`.

---

# Lambda функции

Ламбдите могат да имат само един expression. Не можем да дефинираме променливи или да извикваме команди, макар че в случай на *голяма* нужда, винаги има `execute()`.

Но удобството им е предимно за функции като `map()`, `filter()`, `reduce()`.

---

# Map, filter, reduce

```vim
let numbers = [1, 2, 3, 4, 5]
let doubled_numbers = map(copy(numbers), { i, n -> n * 2 })
" => [2, 4, 6, 8, 10]
let odd_numbers = filter(copy(numbers), { i, n -> n % 2 == 1 })
" => [1, 3, 5]
let numbers_sum = reduce(copy(numbers), { sum, n -> sum + n }, 0)
" => 15
```

Няколко особености/досадности:

* Ламбдите за `map` и `filter` приемат 2 аргумента, първия е индекса на елемента. Но `reduce` приема акумулиращ елемент като първи и няма индекс.
--
    * `map` и `filter` могат да се викат върху речници, тогава "индекса" е ключа.
    * често може да скипваме индекса като `_`
--
* Всичките могат и да се викат върху низове, символ по символ.
--
* Използваме `copy()`, защото функциите са *in place*. Без copy, `map`-а ще замести елементите в същия списък.
--
    * Има `mapnew`, което връща нов списък/речник. Няма други `*new` варианти, реално `mapnew` беше създадено *само* за да избегне типови проблеми.

---

# Map, filter, reduce

Map и filter съществуваха и преди да има ламбди -- eval all the way:

```vim
let numbers = [1, 2, 3, 4, 5]
let doubled_numbers = map(copy(numbers), 'v:val * 2')
" => [2, 4, 6, 8, 10]
let odd_numbers = filter(copy(numbers), 'v:val % 2 == 1')
" => [1, 3, 5]
```

Индекса на елемента е достъпен като `v:key`

---

# Стартиране на външни програми

* Най-базовия начин: `:!`
--
    * Правили сме: `:!mkdir -p ~/.vim/colors`
--
    * Също: `:!curl <some-url> -o autoload/pathogen.vim` (Note: windows също има curl)
--
* С range: `:%!sort`, `:'<,'>!sort`
    * По този начин, stdin на програмата ще е обхванатия текст и ще бъде заместен със stdout-а
    * formatter-и като `js-prettify`, `gofmt` тривиално работят по този начин

---

# Стартиране на външни програми без изчакване

* Под unix, може да стартираме команда без изчакване със `:silent !external-command &`
    * Под моята машина, `:silent !thunar . &`
    * Досадното е, че не redraw-ва. `<ctrl-l>` по default прави това, или `:redraw!`
--
* Под windows, `:!start <command>` ще свърши горе-долу същото
    * `:!start explorer .`
--
* Впрочем, `|` не работи за разделяне на команди, но винаги има `:exe 'silent !thunar &' | redraw!`
--
* Символа `%` се превежда до "текущия файл", а `#` до "алтернативния" (предишния) файл. Т.е. `!firefox %` ще ви отвори текущия файл във firefox.

---

# System

`:help system()`

```vim
let files = system('cd ~/.vim/indent && ls')

echomsg string(files)
" => 'lua.vim^@php.vim^@yaml.vim^@'
echomsg string(split(files, "\n"))
" => ['lua.vim', 'php.vim', 'yaml.vim']
```

---

# Systemlist

`:help systemlist()` -- директно го разбива на празни редове

```vim
let files = systemlist('cd ~/.vim/indent && ls')

echomsg string(files)
" => ['lua.vim', 'php.vim', 'yaml.vim']
```

---

# Systemlist

Впрочем, Vim има `cd`, което може да смени текущата директория, в която се изпълняват команди.

```vim
cd ~/.vim/indent
let files = systemlist('ls')
cd -

echomsg string(files)
" => ['lua.vim', 'php.vim', 'yaml.vim']
```

--

Също има:

* `:help :lcd` -- само в текущия прозорец
* `:help :tcd` -- само в текущия таб
* `:help 'cdpath'` -- директории, които се консултират за релативни пътища

---

# System -- с вход

`:call system(<command>, <input>)`

```vim
let vars = getbufline('%', 1, 4)
      \ ->map({ _, l -> matchstr(l, 'let \zs\k\+\ze =') })
let sorted_vars = systemlist('sort', join(vars, "\n"))
let dummy_var = 42

echomsg string(vars)
" ['vars', '', 'sorted_vars', 'dummy_var']
echomsg string(sorted_vars)
" ['', 'dummy_var', 'sorted_vars', 'vars']
```

---

# Id3.vim demo

--
* `:help fileareadable()`
--
* `:help shellescape()`
--

Справяне с грешки

```vim
let command_output = system('...')
if v:shell_error
  echoerr "There was an error: ".command_output
  return
endif
```

--
* `:help rename()`
--
* `:help :file_f`
* `:help BufReadCmd`, `:help BufWriteCmd`, `:help 'nomodified'`

---

# BufRead/WriteCmd

This club has everything:

* Архиви: `:edit $VIMRUNTIME/plugin/gzip.vim`
--
* Java байткод: <https://github.com/vim-scripts/JavaDecompiler.vim>
--
* Картинки, word документи, PDF-и: <https://github.com/tpope/vim-afterimage/blob/master/plugin/afterimage.vim#L15-L40>
--
* Архиви, отново: <https://github.com/AndrewRadev/archivitor.vim>

---

# Четене и писане на файлове

* `readfile({fname} [, {type} [, {max}]])` -- чете файл по редове
* `writefile({object}, {fname} [, {flags}])` -- пише списък във файл, ред по ред
--
* Удобно: `tempname()`

```vim
TOhtml
exe 'saveas ' .. tempname() .. '.html'
silent !firefox %
redraw! | quit
```

---

# Jobs & Channels

За дългосрочни процеси

```vim
let job = job_start(command, {
      \ 'out_cb':  { job, line -> HandleOutput(line) },
      \ 'err_cb':  { job, line -> HandleError(line) },
      \ 'exit_cb': { job, status -> HandleExit(status) },
      \ })
```

---

# Jobs

Не е нужно да са ламбда функции, разбира се:

```vim
function! HandleOutput(job, line)
  echomsg "Got line: " .. a:line
endfunction

let job = job_start('ls', { 'out_cb': function('HandleOutput') })
echomsg "Info: " .. string(job_info(job))
" => Status: {'status': 'run', 'cmd': ['ls'], 'termsig': '', 'stoponexit': 'term', 'tty_out': '', 'exitval': 0, 'exit_cb': '', 'tty_in': '', 'channel': 'channel 11 open', 'process': 24095}
```

---

# Jobs

* `:help job-options` за всички възможни параметри, които могат да се подадат при стартиране
--
    * (или със `job_setoptions` след като сме го стартирали)
--
* `job_info(job)`: Информация за ID-то на процеса, дава ни командата, callback-овете, които сме инсталирали, всичко
--
* `job_status(job)`: run, fail, dead
--
* `job_stop(job)` -- праща `TERM` сигнал на процеса, но при достатъчно желание, `job_stop(job, "kill")` също работи

---

# Channels

Job-а си стартира с някакъв "канал", по който тече комуникацията, който е в "nl" режим. Т.е. всяко съобщение се завършва с `\n` символ.

--

Може да го вземем с `job_getchannel`, но може и да викаме примерно `ch_sendraw(job)` директно върху job-а, Vim ще се оправи.

--

Засега няма да задълбавам в канали, защото са малко странни и можем и без директно ръчкане в тях.

---

# Gnugo

* `ch_sendraw()`
* Neovim: `jobstart`, `:help on_stdout`, `:help channel-lines`

---

# Clientserver

* Стартираме Vim със `--servername=SOME_NAME`
    * (Трябва да има `+clientserver`)
--
* Стартираме друг Vim със `vim --servername=SOME_NAME --remote-send '<клавиши>'`
--
    * Клавишите се изпълняват в "сървъра"
--
* Стартираме Vim със `vim --servername=SOME_NAME --remote-expr '<expression>'`
--
    * Израза се оценява в сървъра и се печата като резултат
--
* Neovim го махнаха, вероятно защото е имплементирано по странен начин. Опитват се да имплементират нещо като него със сокети, но още не е готово: <https://github.com/neovim/neovim/issues/21600>

---

# Vimrunner

<https://github.com/AndrewRadev/vimrunner>

--

Също интересно, но тепърва ще говорим повече за quickfix прозореца: <https://andrewra.dev/2021/02/01/sending-build-output-to-vim/>

---

# JSON

Функцията `json_encode` превръща Vim-ски обект в JSON, `json_decode` прави обратното. Примерно:

```vim
echo json_encode({ 'key': [1, 2, 3], 'flag': v:true, 'nothing': v:null })
```
```
{"nothing":null,"key":[1,2,3],"flag":true}
```

--

Забележете, Vim няма "null", затова има специалната променлива `v:null` точно за тая цел. Същото за `v:true` и `v:false`.

---

# JS ???

Функцията `js_encode` превръща Vim-ски обект в едно такова като JSON ама не баш, `js_decode` прави обратното. Примерно:

```vim
echo js_encode({ 'key': [1, v:none, 3], 'flag': v:true, 'nothing1': v:null, 'nothing2': v:none })
```
```
{nothing1:null,nothing2:null,key:[1,,3],flag:true}
```
--
Ключовете не са в кавички, има `v:none`, което е еквивалент на undefined???

--
Може би просто не го използвайте.

---

# Id3, отново

И как интерактва със <https://github.com/AndrewRadev/id3-json>.

---

# Terminal

* `:terminal` отваря нов терминален прозорец, потенциално с някаква интерактивна команда, примерно `:term irb`
--
* Ако убием процеса (примерно с Ctrl+D), можем да си обикаляме по буфера
--
* Можем да направим същото като `job_start`, само че със свързан терминален прозорец. Малко е странно:

```vim
function! HandleOutput(job, line)
  echomsg "Got line: " .. a:line
endfunction

let job = term_start('irb', { 'out_cb': function('HandleOutput') })
```

---

# Prompt buffer

Ужасно интересна идея: `:help prompt-buffer`

* Само последния ред може да се "редактира". Но може да излезем в normal mode и да си селектираме каквото си искаме
--
* Когато въведем текст и натиснем Enter, може да извикаме някакъв код със `prompt_setcallback`
--
    * `prompt_setprompt` просто казва как да изглежда prompt-чето на последния ред
    * `prompt_setinterrupt` реагира на Ctrl-C

---

# Prompt buffer

Demo: за systemd интеракция

Side note: https://github.com/vim-scripts/AnsiEsc.vim

---

# Идеи за проект

* Log viewer? Филтриране по параметри, групиране по някакви идентификатори, syntax highlighting...
--
* Chatbot? (нещо човешко като [ELIZA](https://en.wikipedia.org/wiki/ELIZA), за което не ви трябват примерно 10 милиона долара в training costs)
    * С if-клаузи и регекси можете да стигнете доста далеч
--
* HTTP client/graphql client, нещо като [vim-rest-console](https://github.com/diepm/vim-rest-console), ама с интерактивна конзола

---

# Други езици

Ruby, Python, Perl, Lua, могат да се използват директно във Vim... ако е компилиран за целта

```vim
python3 print("Nobody expects the Spanish Inquisition!")
py3file some_python_script.py

python3 << EOF
# The Zen of python:
import this

# More code here...
EOF
```

---

# Други езици

Интеграцията в python става със специалния модул "vim", и е сравнително проста. `:help python-vim`. Проверявате дали има със `has('python3')`

--

Като цяло най-смисления подход е да пишем максимума логика в python, и после да върнем някакъв резултат като низ и да използваме "интеграцията" за базови неща като четене на променливи или вземане на съдържанието на буфера.

--

Същото за всички останали. Guide-овете са `if_ruby.txt`, `if_python.txt` etc, така че ако напишете `:help if_` и натиснете `<tab>`, ще получите пълен списък.

---

# Други езици

Рядко се използват, защото изискват компилация с този език (и то коя версия?). Най-често срещана е python3 интеграция, понякога заради употребата на thread-ове.

Два python плъгина, които ползвам: [ultisnips](https://github.com/SirVer/ultisnips), [autotag](https://github.com/craigemery/vim-autotag).

--

Под neovim, вградените интерпретатори са махнати и `python3` работи като намира външно exe и изпълнява кода през него, комуникирайки с `MsgPack` протокол, стига обаче да има инсталиран "neovim" пакет. `:help provider-python`, `:help remote-plugin`.

Това не е лоша идея, но може да е доста по-бавно, в зависимост от това какво правите.

--

Препоръчвам да си ползвате външни скриптове, които комуникират с текст или JSON.

---

# Други езици

Side note: `:help libcall(`

Бих казал, за такива неща: <https://github.com/mattn/vim-particle>. Но всъщност този плъгин просто си вика exe със `job_start`.

---

# Компилация на Vim

Ужасно лесна под unix, възможна под windows

* Инструкциите под unix са във `src/Makefile` в кода на Vim
* За windows, `src/Make_mvc.mak`
* Може би другия път ще минем през makefile-овете да ги прегледаме
