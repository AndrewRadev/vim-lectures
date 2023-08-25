---
title: Vim9script
author: Андрей Радев
speaker: Андрей Радев
date: 8 юни 2023
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

* Сетъп на плъгини, които навигират проекти
--
* Ctags
--
* Insert-mode completion
--
* Асортирани неща: undo, сесии, vimdiff

---

# Vim9script

--

Защо? Документацията дава две причини:

> The main goal of Vim9 script is to drastically improve performance. This is accomplished by compiling commands into instructions that can be efficiently executed. An increase in execution speed of 10 to 100 times can be expected.

--

Това не е толкова важно, колкото звучи -- bottleneck-а откъм performance много рядко е Vimscript, или поне аз не съм виждал много такива ситуации.

--

Пример: https://github.com/vim-ruby/vim-ruby/pull/443. Има подобрение, но е в много специфичен случай, и проблема е предимно алгоритмичен.

---

# Vim9script

Причина две:

> A secondary goal is to avoid Vim-specific constructs and get closer to commonly used programming languages, such as JavaScript, TypeScript and Java.

--

Това actually е доста по-важното. Vimscript просто има разни досадни проблеми, повечето от които сигурно съм споменавал. Vim9script ги премахва (и въвежда нови, разбира се. Всичко е tradeoff)

---

# Vim9script

Странична бележка: Защо не python/ruby/javascript/lua/lisp?

--

По ред на важност:

1. Vimscript е неутрален
--
    * Програмистките общности си имат собствени идиоми, история, естетика. Познавам ruby програмисти, които мразят python и питонисти, които доста се дразнят на рубистката философия.
--
    * Иначе казано, всички мразят vimscript еднакво много
--
2. Vimscript е прост и лесен за научаване "на части"
--
    * Показах ви vimscript функция в лекция 3, но дори преди това имаше `:set`, `:map`, `:command`
--
    * Чак в лекция 6 минахме през (почти) целия синтаксис на Vimscript, и отне... половин лекция
--
    * Vimscript няма тредове, корутини, класове, монади, ownership semantics, version manager-и... Това е ограничаващо, но освен това го опростява
--
3. Най-важното: Vimscript се използва *само* за Vim и е под контрола на Брам и/или core contributor-ите.

---

# Vim9script

Ако Vim се програмираше на python:

* Първо: щеше да се ползва предимно от python програмисти и да има инструменти предимно за python програмисти.
--
* Второ: щеше да е убит от python3 миграцията
--
* Може би не е съвпадение, че и двата най-стари програмистки редактора, Vim и Emacs, си имат собствени езици

---

# Vim9script

Брам може да промени Vimscript когато и както си иска. Когато се пенсионира, наследниците му ще имат същата сила. Няма нужда да правят промени заради web програмисти (като ruby) или за ML програмисти (като python). Единствения приоритет е Vim и удобства за text editing. През годините, vimscript се сдобива с ламбди, "ООП", а сега и с типове.

--

Javascript-а на VSCode е възможно да се окаже изключение, защото javascript също трябва да бъде fully backwards-compatible... Но той също идва с много тежест, transpilers, node.js, typescript отгоре...

--

Lua-та на Neovim е възможно да се окаже изключение -- тя също е сравнително проста. Но не може да се промени изобщо (фиксирана е на 5.1, всяка нова версия чупи backwards compatibility by design), или може би може да се мигрира с много усилия, или transpiler, fork... Кой знае.

---

# Vim9script

Кратко обобщение: `:help vim9-differences`

---

# Vim9script

%%

```vim
" vimscript

function! Global(one, two) abort
  let sum = s:Local(a:one, a:two)
  let sum += 1

  return sum > 0
endfunction

function! s:Local(one, two) abort
  return a:one + a:two
endfunction
```

%%

```vim
vim9script

def g:Global(one: number, two: number): bool
  var sum = Local(one, two)
  sum += 1

  return sum > 0
enddef

def Local(one: number, two: number): number
  return one + two
enddef

# Опционално, прави typechecking etc веднага:
defcompile
```

%%

---

# Vim9script

Простите неща:

* Скрипта се започва с `vim9script` най-отгоре, позволено е да се направи `if !exists('vim9script')` преди него и туйто
--
* Коментарите вече са `#`, а не `"`
--
* Функциите се дефинират с `def`/`enddef`, script-local са по default, трябва да се дефинират глобални експлицитно (или да се експортнат, повече за това след малко)
--
* Функциите нямат `!` или модификатори като `abort`, скрипта като цяло се зачиства когато се reevaluate-не.
--
* `let` вече е `var` и не може да се декларира повторно

```vim
vim9script

var result: bool

if rand() % 2 == 0
  result = 0
else
  result = 1
endif
```

---

# Vim9script: типове

`:help vim9-types`

* Типовете са задължителни за функции, infer-ват се за декларации на променливи
--
* `bool` е различно от `number` и Vim проверява
--
* И нещо, което го няма в горния списък, но изглежда работи: `any`, което пасва на всеки тип.

---

# Vim9script: функции

* Ограничения: нямате dict функции (но ще имате класове в някакъв момент), нямате речниците `a:` и `l:`
--
* Променливи аргументи: `def Func1(arg1: any, ...rest: list<any>)`
--
* Ламбдите изглеждат по различен начин:

%%
```vim
" vimscript

var Sum = { x, y -> x + y }
```
%%
```vim
vim9script

var Sum = (x, y) => x + y
```
%%

--
Може и така:

```vim
vim9script

var SumPlus1 = (x, y) => {
  var z = x + y
  return z + 1
}
```

---

# Vim9script: речници

%%
```vim
" vimscript

let baz = 'quux'
let example = {
      \ 'foo': 'bar',
      \ 'bar': 'baz',
      \ baz: 'quux',
      \ }
echomsg string(example)
" => {'foo': 'bar', 'bar': 'baz', 'quux': 'quux'}
```
%%
```vim
vim9script

var baz = 'quux'
var example = {
  foo: 'bar',
  bar: 'baz',
  [baz]: 'quux',
}
echomsg string(example)
# => {'foo': 'bar', 'bar': 'baz', 'quux': 'quux'}
```
%%

--

* Няма нужда от line continuations (но *могат* да се ползват)
* Няма нужда от кавички в ключовете (ако нещо трябва да се evaluate-не, `[нещо]`)

---

# Vim9script: команди

* Функции вече могат да се викат без `:call`.
--
    * Но ако искаме да ползваме команда и има шанс да е двузначно, трябва да започнем реда със `:`, примерно: `:substitute(pattern (replacement (`
--
    * Ако искаме range, като `:%delete _`, също трябва да започне с `:`
--
* Командите могат да се имплементират без индирекция (макар че аз бих си използвал функции anyway):

```vim
autocmd BufWritePre *.go {
  var save = winsaveview()
  silent! exe ':%! some formatting command'
  winrestview(save)
}
```

---

# Vim9script: import/export

`:help import`

Обикновена употреба на autoload -- глобална функция:

```vim
inoremap <buffer><expr> <c-x><c-r> rustbucket#complete#Mapping()
```

--

Импорт-ване като script-local променлива:

```vim
import autoload "rustbucket/complete9.vim" as rustComplete
inoremap <buffer> <c-x><c-r> <ScriptCmd>call s:rustComplete.Mapping()<cr>
```

`:help <Cmd>`, `:help <ScriptCmd>`

---

# Vim9script: import/export

Без alias, без autoload (търси в "import" директории в runtimepath):

```vim
import "rustbucket/complete9.vim"
inoremap <buffer> <c-x><c-r> <ScriptCmd>call s:complete9.Mapping()<cr>
```

--

Във vim9script (всичко досега беше стандартен vimscript). Разликата е, че няма `s:`

```vim
vim9script
import "rustbucket/complete9.vim"
inoremap <buffer> <c-x><c-r> <ScriptCmd>call complete9.Mapping()<cr>
```

---

# Vim9script: import/export

Експортвани функции:

```vim
vim9script

export def FunctionName()
  # ...
enddef
```

---

# Vim9script: Demo

* Няколко плъгина за разглеждане:
    * <https://github.com/yegappan/fileselect>
    * <https://github.com/ubaldot/vim-writegood>
    * <https://github.com/Donaldttt/fuzzyy>
--
* vim-ruby
* fuzzy finder
* rust completion

---

# Vim9script: Заслужава ли си?

--

Програмистките подобрения не са лоши, а типовете хващат някои проблеми. Поне според мен, обаче, липсва част от простотата на "legacy" vimscript и си има своите нови странности.

--

Времето ще покаже 🤷. Както съм казвал и преди, не е нужно една технология да "спечели" или да "загуби". It's just sort of there, който иска да го ползва. Включително за проектите ви.

---

# Асорти

--

* Собствени text-objects (`:help omap-info`)
* Собствени оператори (`:help map-operator`)
* Профилиране (`:help profile`)
* Textprops (`:help text-properties`)
    * <https://www.youtube.com/watch?v=NBdPqMBRQuM>
* Popup-и (`:help popup-functions`)
    * Side note: `:help win_execute()`
* JSON канали и контролиране на Vim с тях: `:help channel-demo`
    * Side note: Трикове със clientserver и Rust: <https://andrewra.dev/2021/02/01/sending-build-output-to-vim/>
* Тестове:
    * Вече съм го показвал: <https://github.com/AndrewRadev/vimrunner>
    * Contest: <https://github.com/airblade/vim-contest>
    * Vader: <https://github.com/junegunn/vader.vim>
