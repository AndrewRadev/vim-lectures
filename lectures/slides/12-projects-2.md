---
title: Работа с проекти 2, организация на плъгини
author: Андрей Радев
speaker: Андрей Радев
date: 30 май 2023
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

* LSP
--
* Fuzzy-finding
--
* Command-line completion
--
* Команди за търсене на *категория* от неща

---

# Скелет на един плъгин

* Аз буквално си имам скрипт за това: [`newplugin`](https://github.com/AndrewRadev/scripts/blob/7f48f3d1c79450c50ddc80cd1a2bb8ba65aeb745/bin/newplugin)
--
* Стандартните директории: autoload, plugin, doc, понякога ftplugin
--
* `:help cp`, `:help cpo` -- днешно време едва ли имат значение, но не е лоша идея да се ползват като част от "скелета"
--
* `g:loaded_newplugin` -- За да се подсигурим, че ще се зареди само веднъж и да дадем лесен начин да се изключи
--
* Настройки: `g:newplugin_setting` -- изглежда просто, но работи перфектно

---

# Организация на данните

Ако имаме една купчина `b:` променливи, защо да не ги съберем в един обект?

```vim
function! fluffy#finder#New()
  let job = job_start('rg --files', ...)

  return #{
        \   statusline:    '',
        \   all_paths:     [],
        \   start_time:    reltime(),
        \   last_update:   reltime(),
        \   duration:      0,
        \   loading:       ['⢿', '⣻', '⣽', '⣾', '⣷', '⣯', '⣟', '⡿'],
        \   loading_index: 0,
        \   job:           job,
        \ }
endfunction

let b:finder = fluffy#finder#New()
```

---

# Организация на данните: (нещо като) ООП

`:help func-dict`

```vim
function! fluffy#finder#New()
  return #{
        \   ...
        \   Update: function('s:Update'),
        \   Stop:   function('s:Stop'),
        \ }
endfunction

autocmd TextChangedI <buffer> call b:finder.Update()
autocmd QuitPre      <buffer> call b:finder.Stop()

function s:Update() dict
  " ...
endfunction

function s:Stop() dict
  " ...
endfunction
```

---

# Организация на данните: (нещо като) ООП

Няма наследяване или класове, но пък има начин да съберете данни и поведение, и това може да е напълно достатъчно.

--

При достатъчно желание, може и да се постигне някаква форма на наследяване, примерно парсърите в [splitjoin](https://github.com/AndrewRadev/splitjoin.vim/tree/c00fa513974811e7bdf34b3d8a53abbd69c9042c/autoload/sj/argparser).

--

Внимавайте с функциите -- `b:finder.Update()` ще извика функцията със `b:finder` прикачено като self. Но ако я подадете като аргумент или прикачите някъде, ще гръмне:

```vim
" Ще хвърли грешка:
let Update = b:finder.Update
call Update()

" Ще бъде ок 👍
let Update = { -> b:finder.Update() }
call Update()
```

---

# Грешки във функция

Странно качество на Vimscript: ако някой ред хвърли грешка, скрипта смело ще си продължи напред.

```vim
function! Test()
  if nonexistent_var
    echomsg "OK1"
  endif

  echomsg "OK2"
endfunction

call Test()
```

```
Error detected while processing /tmp/vHfVvdg/9[9]..function Test:
line    1:
E121: Undefined variable: nonexistent_var
OK2
```

---

# Грешки във функция

Това е изключително безсмислено за general-purpose език, но има смисъл за *конфигурационен език*, което Vimscript частично е. Ако имате в конфигурацията си една грешка, не искате редактора да откаже да boot-не... Защото няма с какво да оправите грешката.

--

В контекста на функция това няма много смисъл. Затова има атрибута `abort` (`:help func-abort`):

```vim
function! Test() abort
  if nonexistent_var
    echomsg "OK1"
  endif

  echomsg "OK2"
endfunction

call Test()
```

```
Error detected while processing /tmp/vHfVvdg/10[9]..function Test:
line    1:
E121: Undefined variable: nonexistent_var
```

---

# Грешки във функция

Докато сме на тази тема -- забележете малко странния backtrace -- "line 1"? Това е поредния ред *във функцията* 🤷.

Nest-ването също е малко странно:

```vim
function! Test1() abort
  echomsg "OK0"
  if nonexistent_var | echomsg "OK1" | endif
  echomsg "OK2"
endfunction

function! Test2() abort
  echomsg "OK3"
  call Test1()
endfunction
```
```
OK3
OK0
Error detected while processing function Test2[2]..Test1:
line    2:
E121: Undefined variable: nonexistent_var
```

---

# Грешки във функция

Един плъгин, който се опитва да направи този backtrace по-лесен: [exception.vim](https://github.com/tweekmonster/exception.vim). Но е малко бъгав.

---

# Документация

Няма един начин, но има някои полезни компоненти:

--
* `*myplugin-section*` -- звездичките ограждат нещо, на което може да се скочи
--
* `|myplugin-section|` -- тръбичките ограждат линк към това нещо
--
* Тези ограждащи символи са скрити с "conceal" (`:help syn-conceal`).
--
* Имплементация: тагове. Символ, файл, search pattern, разделени със `\t` символи. `:help helptags`

---

# Документация

* Код може да се пише в backtics, но обикновено за команди или настройки на плъгина, се ползва `|:Command|`, за да е освен това линк.
--
* Многоредов код се започва с `>` и завършва с `<` на отделен ред, като между тях трябва да има индентация
--
* Голямо заглавие е в началото на ред, `UPPERCASE`, малко заглавие е в началото на ред и завършва със `~`
--
* Може да разгледате вградените help файлове или `$VIMRUNTIME/syntax/help.vim` за още дребни неща

---

# Да се върнем на навигацията за проекти

* `:Emodel solution`
--
* `:Econtroller announcement`
--
* Как да направим `:Efactory vimrc_revision`?

---

# Как да намерим factory?

Може да направим същото, но в един файл може да има няколко factory-та:

```ruby
FactoryBot.define do
  factory :vimrc do
    user
  end

  factory :vimrc_revision do
    vimrc
    body { "set number\nset expandtab" }
  end
end
```

---

# Как да намерим factory?

1. Намираме файловете
1. Минаваме през редовете на всеки файл
1. Намираме `^\s*factory :\k\+` или нещо подобно

Тъпо, но тотално работи

---

# Quickfix

Най-простия начин:

```vim
command! ListFactories call s:ListFactories()

function! s:ListFactories()
  vimgrep /^\s*factory :\zs\k\+/j spec/**/*.rb
  copen
endfunction
```

---

# Quickfix: Базови неща

* `:help grepprg` и `:help grepformat` -- говорили сме, но преди доста време
--
* Оригиналната причина за quickfix са `compiler` плъгините.
    * `:help compiler`
--
    * `:help makeprg`
--
    * `:help errorformat`

---

# Quickfix

Може да изпълним "компилатор" с `make` или даже `make some args`, компилатора може да е локален за файла или глобален за проекта. Но това ни зарежда грешките в quickfix прозореца.

--

Същото прави и vimgrep/grep. Целта е просто да заредим *локации* в някакъв интерфейс

---

# Quickfix

Можем и да направим така (`:help cexpr`)

```vim
cexpr systemlist('rg "factory :\w+" spec/ --vimgrep')
```

`cexpr` използва `errorformat`, така че можем ако искаме да сложим нещо custom като формат и да го restore-нем след това.

---

# Quickfix

Най-гъвкавия начин: `:help setqflist()`

```vim
for filename in s:FindFactoryFiles()
  for [line_index, line] in items(readfile(filename))
    let pattern = '^\s*factory :\zs\k\+\ze\s*\%(,\|do\)'

    if line =~ pattern
      let [_match, start_index, _end_index] = matchstrpos(line, pattern)

      call add(factory_entries, #{
            \   filename: filename,
            \   lnum:     line_index + 1,
            \   col:      start_index + 1,
            \   text:     trim(line),
            \ })
    endif
  endfor
endfor

if len(factory_entries) > 0
  call setqflist(factory_entries)
  copen
endif
```

---

# Quickfix

Setqflist има тонове опции, повечето от които не съм пробвал:

--
* `setqflist(..., 'a')` ще добави ("append") неща към списъка
--
* `:call setqflist([], 'a', {'id':qfid, 'efm': '%f#%l#%m', 'lines': ['F1#10#Line']})` ще игнорира първия аргумент и ще изпарси "lines" със дадения "error format" и ще ги добави към списъка с id `qfid` (което може да се вземе от `getqflist()`)
--
* В последния речник могат да се сложат `title` и `quickfixtextfunc`, които да променят как се рендерира списъка
--
* Има и `context` поле, което може да е какъвто и да е речник или списък, който държи някаква допълнителна информация

---

# Quickfix

`:help getqflist()`

Същото, ама за четене

```vim
ListFactories
for entry in getqflist() | echomsg string(entry) | endfor
```
```vim
{'lnum': 2, 'bufnr': 11, 'end_lnum': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': 0, 'module': '', 'type': '', 'end_col': 0, 'col': 12, 'text':
'factory :announcement do'}
{'lnum': 2, 'bufnr': 12, 'end_lnum': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': 0, 'module': '', 'type': '', 'end_col': 0, 'col': 12, 'text':
'factory :comment do'}
{'lnum': 2, 'bufnr': 13, 'end_lnum': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': 0, 'module': '', 'type': '', 'end_col': 0, 'col': 12, 'text':
'factory :free_task_solution do'}
```

И пак има `context`, `title`, etc

---

# Quickfix

Защо сложните `getqflist()`/`setqflist()` вместо vimgrep/grep/cexpr?

--

Защото са функции, които просто си работят с речници и списъци:

* <https://github.com/AndrewRadev/qftools.vim>
--
* <https://github.com/AndrewRadev/writable_search.vim>
--
* <https://github.com/AndrewRadev/quickpeek.vim>
--
    * За повече информация, ако ви е интересно: https://www.youtube.com/watch?v=1AOhfnokacE

---

# Quickfix

За какво можем да го използваме?

* Намери срещания на символ -- kind of очевидно, grep/ack/ripgrep ще ни свърши работа
--
* Намери кои файлове import-ват този файл? Това вече е малко по-неочевидно
    * `cexpr system('find-imports ' .. shellescape(expand('%')))`
    * Разбира се, може да се имплементира с Vim регекси, но може и примерно да си направите индекс на импортите като парсите примерно Rust файлове със [syn](https://docs.rs/syn/latest/syn/)
--
* Отвори ми всички файлове/позиции, свързани с текущия -- тест, view, route, factory...
    * Което може да е добър use case за `:help location-list`
--
* Bookmarks -- може би не съвсем за навигация на проекти, но:
    * <https://github.com/AndrewRadev/simple_bookmarks.vim>
    * <https://github.com/MattesGroeger/vim-bookmarks>

---

# Още навигация

* Често се използва `gf`, "go to file". Оригинално е за файлоподобни неща, но Tim Pope го abuse-ва като "намери файла на този символ" във vim-rails.
--
* Аз го до-abuse-вам, като добавям и позициониране на курсора после: <https://andrewra.dev/2016/03/09/building-a-better-gf-mapping/>
--
* Начина, по който би трябвало да се прави това е чрез `:help includeexpr`, но досаден проблем е, че то се trigger-ва само ако вече няма файл с това име.
    * Tim Pope просто си прави мапингите на ръка: [vim-rails](https://github.com/tpope/vim-rails/blob/959e94b76e6ebdf984acef61649ba7d0f62bd425/autoload/rails.vim#L4851-L4873)
--
* Важна бележка: изобщо не е нужно да е `gf`. Може да си направите `:FindTranslation`, `:FindImport` etc.

---

# Още навигация

* Още примери във:
    * [rails_extra](https://github.com/AndrewRadev/rails_extra.vim/blob/main/autoload/rails_extra.vim#L3-L20)
    * [rustbucket](https://github.com/AndrewRadev/rustbucket.vim/blob/f62c3faf19f22bb0a84d60fc20c300dfbfa0a504/autoload/rustbucket/gf.vim#L1-L39)

--

Като цяло, ако имате език с импорти (rust, typescript, java), винаги може да "проследите" импортите. Ако имате език без импорти (ruby, vimscript), вероятно има някаква конвенция, която може да ползвате. Задайте си въпроса "как бих намерил това нещо на ръка" и опитайте да го автоматизирате.

--

* Има и други хакове, като [да отваряте браузъра и да търсите информация от съдържанието](https://github.com/tpope/vim-rails/blob/9c3c831a089c7b4dcc4ebd8b8c73f366f754c976/autoload/rails.vim#L2695-L2724)
* Конкретно за translations, може да разгледате [rtranslate](https://github.com/AndrewRadev/rtranslate.vim), кода не е много и може да ви даде идеи
