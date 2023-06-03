---
title: Ctags, Completion
author: Андрей Радев
speaker: Андрей Радев
date: 1 юни 2023
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

* Структура на един плъгин, документация
    * (Идея за use/abuse на doc таговете [за бележки](https://www.reddit.com/r/vim/comments/133x5jc/weekly_vim_tips_and_tricks_thread_21/>))
--
* Организация на код и данни в "обекти"
--
* Quickfix, makeprg, compiler
--
* Още навигация -- "намери ми символ"

---

# Довършващи неща: Дефиниране на функции за навигация

Вариант 1: глобални команди в локален файл

```vim
" Check if editing a directory
autocmd VimEnter * call s:MaybeEnterDirectory(expand("<amatch>"))

function! s:MaybeEnterDirectory(file)
  if a:file == '' || !isdirectory(a:file)
    return
  endif

  let dir = a:file
  exe "cd ".fnameescape(dir)

  if filereadable('_project.vim')
    edit _project.vim
    setfiletype vim
    source _project.vim
  endif
endfunction
```

Оттам мога да извикам примерно `runtime! projects/rails.vim`: [Vimfiles/projects/](https://github.com/AndrewRadev/Vimfiles/tree/71283753e87c1dad4e50195968fd00d3a4dd07f9/projects)

---

# Довършващи неща: Дефиниране на функции за навигация

* Потенциално може да пробвате `:help 'exrc'`
--
* Или този ужасяващо стар плъгин: [Proj](https://github.com/vim-scripts/Proj)
--
    * Впрочем: "организация на проекти" не е лоша идея за проект

---

# Довършващи неща: Дефиниране на функции за навигация

Вариант 2: буфер-локални променливи (the Tim Pope way)

```vim
autocmd FileType * if RailsDetect() | call rails#buffer_setup() | endif
```

И една купчина други [аутокоманди](https://github.com/tpope/vim-rails/blob/959e94b76e6ebdf984acef61649ba7d0f62bd425/plugin/rails.vim#L100-L136)

Detection-a се свежда до "има ли Gemfile.lock" в родителска директория (`:help findfile()`). И командите се дефинират само в този буфер и така във всеки следващ.

---

# Довършващи неща: Ctags

Ако минем твърде бързо, или ви се чете, две стари статии:

* <https://andrewra.dev/2011/06/08/vim-and-ctags/>
* <https://andrewra.dev/2011/10/15/vim-and-ctags-finding-tag-definitions/>

---

# Ctags: История

Оригиналния ctags е само за C, hence the name. После излиза [Exuberant ctags](https://ctags.sourceforge.net/), което започва да се използва мега много, и наскоро [Universal ctags](https://github.com/universal-ctags/ctags), което е поддържаната версия.

Съществуват разни language-specific алтернативи за [haskell](https://wiki.haskell.org/Tags), за [rust](https://github.com/dan-t/rusty-tags), за [ruby](https://github.com/tmm1/ripper-tags), със смесен успех.

---

# Ctags: Генериране

```
ctags -R .
```

Ако искате да индексирате и пакетите, освен вашия код, трябва да намерите директориите им. Аз имам [bundle-tags](https://github.com/AndrewRadev/scripts/blob/7f48f3d1c79450c50ddc80cd1a2bb8ba65aeb745/bin/bundle-tags) за руби и [cargo-tags](https://github.com/AndrewRadev/scripts/blob/7f48f3d1c79450c50ddc80cd1a2bb8ba65aeb745/bin/cargo-tags) за Rust (което използва [cargo-local](https://github.com/AndrewRadev/cargo-local))

---

# Ctags: Употреба

* `<C-]>` на символ (`:help CTRL-]`)
--
* `:tselect <tag>`
--
* И една купчина други: `:help tags-and-searches`
--
* Вкарване в quickfix прозореца: <https://github.com/AndrewRadev/tagfinder.vim>
--
* Completion: `<C-X><C-]>` (`:help CTRL-X_CTRL-]`)
    * Имате и `getcompletion`, примерно `echo getcompletion('Hash', 'tag')` ще ви даде HashMap, HashSet, Hasher...

---

# Ctags: Сериозна употреба

* `:help taglist()` -- намира тагове по регекс. Много добра идея е винаги регекса да започва със `^`, защото Vim може да намери match-овете с binary search. `:help tag-regexp`
--
* Таговете могат да съдържат метаданни, които да ви дадат информация това клас ли е, trait ли е, enum ли е?
--
* Примерно: [rustbucket](https://github.com/AndrewRadev/rustbucket.vim/blob/f62c3faf19f22bb0a84d60fc20c300dfbfa0a504/autoload/rustbucket/identifier.vim#L147-L180)
--
* `:help tagfunc`, и пример за употреба във моите [Vimfiles](https://github.com/AndrewRadev/Vimfiles/blob/71283753e87c1dad4e50195968fd00d3a4dd07f9/ftplugin/vim.vim#L69-L95)

---

# Ctags: Сериозно генериране

* [autotag](https://github.com/craigemery/vim-autotag) -- иска python
--
* [gutentags](https://github.com/ludovicchabant/vim-gutentags) -- едно време ми беше бъгав, но преди *много* време
--
* Git hooks? <https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html>
--
* Ако нещо не сработи, просто регенерирам 🤷
    * [`:RebuildTags`](https://github.com/AndrewRadev/Vimfiles/blob/71283753e87c1dad4e50195968fd00d3a4dd07f9/startup/commands.vim#L34-L50) отнема по-малко от секунда на доста голям проект

---

# Ctags: Има ли смисъл?

* Накратко: да
--
* Ctags не е перфектно, но много рядко ви трябва "перфектно". "Намери символ" работи супер почти винаги. В ситуациите, в които не работи (примерно функция, която се казва "call" или "new"), обикновено ще имате други начини за навигация
--
* LSP сървър може да ви даде *много* по-прецизна информация (ако ви се чака), но
    * Има много по-малко покритие на езици и технологии
    * Има си своите бъгове (кой както го е имплементирал)
    * Доста по-тежко е
--
* Тагове могат да се генерират с [регекси](https://github.com/rust-lang/rust.vim/blob/889b9a7515db477f4cb6808bef1769e53493c578/ctags/rust.ctags), но могат и да се генерират с истински парсър като [syn](https://crates.io/crates/syn). Формата е ужасно прост.
--
* Както винаги, напомням че не е нужно да имате *само един* начин да навигирате и манипулирате код.

---

# Ctags: Идеи за проекти

* Gutentags/Autotag клонинг, защо не?
--
* LSP сървър, който използва ctags?
--
* Генератор на тагове за любим език? (интеграция с Vim в случая ще рече -- използва метаданните в таговете за нещо интересно, умен completion, линкове към документация...).
--
* Просто може да използвате каквото имате от ctags като метаданни като част от друг проект

---

# Insert-mode Completion

`:help ins-completion`

* `:help CTRL-X_CTRL-N` -- completion на думи в буфера
--
* `:help CTRL-X_CTRL-L` -- completion на цели редове
--
* `:help CTRL-X_CTRL-F` -- completion на файлове
--
* `:help CTRL-X_CTRL-]` -- completion на тагове
--
* `:help CTRL-X_CTRL-V` -- completion на vim команди

---

# Insert-mode Completion

`:help complete-functions`

* `:help CTRL-X_CTRL-U` -- user completion със `&completefunc`
    * Интересна default-на стойност: `set completefunc=syntaxcomplete#Complete`
* `:help CTRL-X_CTRL-O` -- user completion със `&omnifunc`

---

# Insert-mode Completion

Пример: strftime completion: [strftime.vim](https://github.com/AndrewRadev/strftime.vim/blob/main/autoload/strftime.vim#L37-L58)

Функцията се вика два пъти, веднъж със `findstart` истина, веднъж лъжа. При първото викане, искаме да върнем на коя колона започва completion-а. При второто, връщаме списък с думи, които complete-ват:

```vim
function! strftime#Complete(findstart, base)
  if a:findstart
    " Намери началото и върни номер на колона или отрицателно число, за да спреш completion-а
  else
    " Върни списък от думи, или `{ word: ..., menu: ..., ... }`
  endif
endfunction
```

---

# Rust импорти

* Регекси, регекси, регекси
--
* Как да проверим, че символите са usable? Може да пробваме `taglist('^', item, filename)`

---

# Готин трик

```vim
inoremap <expr> <Plug>StrftimeComplete <SID>CompleteOnce()

function s:CompleteOnce()
  let b:saved_completefunc = &completefunc
  set completefunc=strftime#Completefunc

  autocmd CompleteDone * ++once let &completefunc = b:saved_completefunc
  autocmd CompleteDone * ++once unlet b:saved_completefunc

  return "\<c-x>\<c-u>"
endfunction
```

Можем да си изберем наша клавишна комбинация примерно със:

```vim
imap <c-x><c-d> <Plug>StrftimeComplete
```

---

# Какво е `<SID>`?

Това би дало грешка:

```vim
inoremap <expr> <Plug>StrftimeComplete s:CompleteOnce()
```
```
E120: Using <SID> not in a script context: s:CompleteOnce
```

Функцията `s:CompleteOnce` е script-local... Но когато изпълняваме мапинга, той все едно бива "написан" в командния ред, което е различен контекст.

Конкретно при мапинги, скрипт-локални функции и променливи могат да се реферират със `<SID>`. `:help <SID>`

---

# Completion

Има много повече за четене, но не го ползвам често. Ако решите да пишете completion script за проект, започнете от това да прочетете цялата документация във

* `:help complete-functions`, и може би също така:
* `:help 'completeopt'`
* `:help CompleteChanged`
* `:help pumvisible()`

---

# Completion: примери

* Всички "complete" функции във `$VIMRUNTIME`: [runtime/autoload/](https://github.com/vim/vim/tree/master/runtime/autoload)
--
* Perl completion-а, който писахме със Стефан в някакъв изблик и той не е използвал оттогава: [ftplugin/perl.vim](https://github.com/skanev/dotfiles/blob/5ab282e4047882b885b65a41b0e1bfe547c6a7b1/vim/ftplugin/perl.vim#L35-L76)
--
* Интересна функция, която е по-умен line completion: <https://www.reddit.com/r/vim/comments/13v0mz2/line_suffix_completion/> (писана на vim9script, но за това следващата лекция)
--
* Rust нещата ще ги кача някъде в някакъв момент

---

# Автоматичен completion

* [Acp](https://github.com/vim-scripts/AutoComplPop) -- *мега* стар плъгин
--
    * ... който аз използвам с ей тези настройки: [acp.vim](https://github.com/AndrewRadev/Vimfiles/blob/71283753e87c1dad4e50195968fd00d3a4dd07f9/startup/acp.vim)
--
* [mucomplete](https://github.com/lifepillar/vim-mucomplete) -- вероятно по-добра идея и доволно популярен
--
* Може би [asyncomplete](https://github.com/prabirshrestha/asyncomplete.vim), макар че целта му изглежда малко различна

---

# Асорти

--

* Tim Pope има плъгин за писане на плъгини: <https://github.com/tpope/vim-scriptease>
* Undo (`:help undo-tree`, [mundo](https://github.com/simnalamburt/vim-mundo), [Gundo](https://github.com/sjl/gundo.vim))
* Сесии (`:help mksession`)
* Vimdiff (`:help vimdiff`, `:help 'diffopt'`)
* `:help <Leader>`, `:help <Localleader>`
