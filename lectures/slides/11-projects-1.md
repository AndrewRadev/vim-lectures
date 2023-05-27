---
title: Работа с проекти 1
author: Андрей Радев
speaker: Андрей Радев
date: 25 май 2023
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

* Приключихме с упражненията, кой каквото изкарал
    * Все още имате свободни упражнения: <https://vim-fmi.bg/free_tasks>
* Извънредна лекция:
    * Вторник, зала 229, или
    * Петък, зала 200?

---

# Преговор

* Neovim: Религиозни спорове
--
* LSP
--
* Telescope
--
* Tree-sitter
--
* Lua

---

# Как работим с проекти?

Няма един начин, но има тонове инструменти. Ще започна от най-скучните (за мен).

---

# LSP

--
* <https://github.com/prabirshrestha/vim-lsp>, който ще пробваме след малко
--
* <https://github.com/yegappan/lsp> -- писан на vim9script
--
* <https://github.com/natebosch/vim-lsc> -- още един, този път с различно име :)
--
* "Conquer of Completion": <https://github.com/neoclide/coc.nvim>. Оригинално за completion, днешно време general-purpose LSP
--
* Async Lint Engline: <https://github.com/dense-analysis/ale>. Оригинално за lint-ване (и все още работи с тези инструменти), днешно време general-purpose LSP
--
* И твърде много други...

---

# Vim-lsp setup

Rust-analyzer: https://rust-analyzer.github.io/manual.html#installation

Препоръката от плъгина:

```vim
if executable('rust-analyzer')
  au User lsp_setup call lsp#register_server({
        \   'name': 'rust-analyzer',
        \   'cmd': { _server_info -> ['rust-analyzer'] },
        \   'allowlist': ['rust'],
        \ })
endif
```

---

# Vim-lsp setup

Rust-analyzer: https://rust-analyzer.github.io/manual.html#installation

Това, което аз бих направил:

```vim
augroup LspSetup
  autocmd!
  autocmd User lsp_setup call s:LspSetup()
augroup END

function! s:LspSetup()
  if executable('rust-analyzer')
    call lsp#register_server({
          \   'name': 'rust-analyzer',
          \   'cmd': { _server_info -> ['rust-analyzer'] },
          \   'allowlist': ['rust'],
          \ })
  endif
endfunction
```

Във `ftplugin/rust.vim`: `call lsp#enable()`

---

# Vim-lsp

* `:Lsp<tab>` ще ви даде тонове неща
--
* On hover се праща тонове информация, която се пази като "code actions" (`:LspCodeAction`)
--
* `:LspRename`

---

# LSP

Защо ми е скучно? (Не *лошо*, просто скучно)

--
* Имаме code actions, какво правим с тях? Как ги customize-ваме?
--
    * Отговор: (почти никак). Или ги използвате, или не.
--
    * Каквото даде сървъра -- ако има бъгове или неудобства, идете в проекта да помагате и чакайте евентуално да стигне до вас. Или може да си го компилирате from source, I guess
--
* Клиента обикновено е generic към сървъри.
    * Предимство: интеграцията с всички сървъри работи по един и същ начин
--
    * Недостатък: интеграцията с всички сървъри *трябва* да работи по един и същи начин
--
* UI-а не е особено "плавен" и пак, не е много лесно да се тунингова. Но ще видим как можем да си направим наши инструменти...

---

# Vim-lsp

Моите настройки:

```vim
" Аз бих го активирал с `lsp#enable()` per-filetype
let g:lsp_auto_enable = 0

" За да използваме специализирани канали за performance:
let g:lsp_use_native_client = 1

" Добра идея, но в зависимост от сървъра, може буквално да нарастне до гигабайти:
let g:lsp_log_file = expand('~/.vim-lsp.log')
```

"Native client" каналите: <https://github.com/vim/vim/commit/9247a221ce7800c0ae1b3487112d314b8ab79f53>

---

# LSP канали

Или как да си го направим сами:

```vim
let job = job_start('rust-analyzer', {
      \ 'in_mode': 'lsp',
      \ 'out_mode': 'lsp',
      \ 'err_mode': 'nl',
      \ 'out_cb': function('s:LspOut'),
      \ 'err_cb': function('s:LspErr'),
      \ })

function! s:LspOut(_job, message)
  echomsg 'Err: ' .. string(a:message)
endfunction

function! s:LspErr(_job, message)
  echomsg 'Out: ' .. string(a:message)
endfunction
```

---

# LSP канали

* `findfile('Cargo.toml', '.;')`
    * `:help findfile()`, но по-скоро
    * `:help file-searching`
--
    * Препоръчвам да го ползвате само за търсене нагоре, но си разгледайте документацията, ако ви се експериментира
--
* `help fnamemodify()`
    * `:help filename-modifiers`
    * `fnamemodify(cargo_file, ':p:h')` -- вземи "главата" (родителската директория) от пълния път на `Cargo.toml` файла.

---

# LSP канали

Без jobs:

```vim
let channel = ch_open({address} [, {options}])
if ch_status(channel) == "open"
  " use the channel
```

---

# LSP канали

`:help channel-address`

```
www.example.com:80   " domain + port
127.0.0.1:1234       " IPv4 + port
[2001:db8::1]:8765   " IPv6 + port
unix:/tmp/my-socket  " Unix-domain socket path
```

Т.е. ако имаме сървър на някой TCP порт, може да се вържем директно с нещо като:

```vim
let channel = ch_open('127.0.0.1:1234', { 'mode': 'lsp' })
```

---

# LSP канали

Изпращане на request:

```vim
let response = ch_evalexpr(job, {
      \   'method': 'initialize',
      \   'params': {
      \     'processId': getpid(),
      \     'rootUri': root_uri,
      \     'rootPath': root_path,
      \     'capabilities': {...},
      \   },
      \ })
```
--

`:help ch_evalexpr()`

```
ch_evalexpr() waits for a response and returns the decoded
expression.  When there is an error or timeout it returns an
empty |String| or, when using the "lsp" channel mode, returns an
empty |Dict|.
```

---

# LSP канали

Изпращане на "notification", one-way (kind of):

```vim
call ch_sendexpr(job, {
      \   'method': 'textDocument/didOpen',
      \   'params': {
      \     'textDocument': {
      \       'uri': 'file://' .. expand('%:p'),
      \       'languageId': 'rust',
      \       'version': b:changedtick,
      \       'text': join(getbufline('%', 1), "\n")
      \     },
      \   },
      \ })
```

--

`:help ch_sendexpr()`

```
If the channel mode is "lsp", then returns a Dict. Otherwise
returns an empty String.  If the "callback" item is present in
{options}, then the returned Dict contains the ID of the
request message.  The ID can be used to send a cancellation
request to the LSP server (if needed).  Returns an empty Dict
on error.
```

---

# LSP канали

Това е всичко... на теория. На практика има ужасяващо много дребни детайли, които са мега досадни за имплементация. API документацията изглежда почти активно engineered да е user-hostile.

* Началото на документацията: <https://microsoft.github.io/language-server-protocol/>
* Спецификация: <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/>
* Мнение от преди 4 години: <https://www.reddit.com/r/ProgrammingLanguages/comments/b46d24/a_lsp_client_maintainers_view_of_the_lsp_protocol/>

---

# LSP: Проекти?

Ако искате да имплементирате нещо с LSP... по-добре недейте. Но ако много настоявате, няколко идеи:
--
* Базов сървър, който имплементира нещо конкретно -- форматиране, диагностики, едно-две дребни неща. Този stream може да ви бъде полезен: <https://www.youtube.com/watch?v=9fJntxnH4wY> (дълъг е, но само последните 30тина минути са код)
--
* Клиент, който таргетира *конкретен* сървър -- rust-analyzer, gopls, clangd... Може да инспектирате резултатите и да имплементирате *удобни* действия вместо да имате general-purpose UI направен като за VSCode.
--
* Generic client мисля, че ще бъде твърде досадно, но ако настоявате, няма да ви спра.
--
* Спокойно може да използвате LSP каналите само като транспортен механизъм -- вие си пишете някаква програма, която пише на STDOUT и чете от STDIN json, енкоднат със <code>Content-Length: ...</code> и т.н.. Не е нужно да имплементирате application-level протокола, за да се възползвате от удобния начин да размятате json-и между клиент и сървър.

---

# Fuzzy finding

Плъгини има доста:

--
* CtrlP: <https://github.com/ctrlpvim/ctrlp.vim>
--
* FZF: <https://github.com/junegunn/fzf.vim>
--
* Telescope: <https://github.com/nvim-telescope/telescope.nvim>

---

# Fuzzy finding

Demo

---

# Fuzzy finding

`:help matchfuzzy()`, `:help fuzzy-matching`

```vim
echo matchfuzzy(["clay", "crow"], "cay")
" => ['clay']
echo matchfuzzy(v:oldfiles, "test", { 'limit': 3, 'matchseq': 1 })
" => [
"   '~/.vim/bundle/tagalong/test.erb',
"   '~/.vim/bundle/tagalong/test.html',
"   '~/.vim/.git/modules/bundle/tagalong/COMMIT_EDITMSG'
" ]
```

---

# Fuzzy finding

`:help matchfuzzypos()`

```vim
echo matchfuzzypos(["clay", "crow"], "cay")
" => [['clay'], [[0, 2, 3]], [150]]

for entry in matchfuzzypos(v:oldfiles, "test", { 'limit': 3, 'matchseq': 1 })
  echomsg string(entry)
endfor
" ['~/.vim/bundle/tagalong/test.erb', '~/.vim/bundle/tagalong/test.html', '~/.vim/.git/modules/bundle/tagalong/COMMIT_EDITMSG']
" [[23, 24, 25, 26], [23, 24, 25, 26], [10, 17, 18, 27]]
" [208, 207, 77]
```

---

# Fuzzy finding: aside

* Оригинален PR (merge-нат 11 септември, 2020): <https://github.com/vim/vim/pull/6932>
* Neovim PR (merge-нат 8 февруари, 2022): <https://github.com/neovim/neovim/pull/16873>
--
* Няма такова нещо като "Neovim са иноватори, Брам краде", проектите се подобряват взаимно, дори и понякога да имат различни решения на проблемите.

---

# Fuzzy finding

Алгоритмичния проблем е предимно решен. Пак може да ползвате външен инструмент или lua на Neovim за собствен алгоритъм, но ако просто искате нещо, което работи достатъчно добре, вземате `matchfuzzypos` и измисляте как да го представите.

--

* Highlighting с колони и редове
--
* `:help text-properties`
    * Би трябвало да говоря пак за тях, но за всеки случай: <https://www.youtube.com/watch?v=NBdPqMBRQuM>
--
* `:help command-modifiers`

---

# Fuzzy finding: Проекти?

* Fuzzy finder? 🤷
--
* Може да се ползва като механизъм за търсене на доста неща. Не съм му голям фен, но повече за това по-късно.

---

# Структурата на един Rails проект

Demo

* Routes
    * `bin/rails routes`
--
* Controllers + Views
--
* Models
--
* Tests/Specs, factories

---

# Как да намерим модел?

--

Ужасно е лесно:

```vim
command! -nargs=1 Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  exe 'edit app/models/'.a:model_name.'.rb'
endfunction
```

... но не е много приятно за употреба

---

# Command-line completion

* `:help command-complete`
* `getcompletion()`
--
* `:help command-completion-custom`

---

# Как да намерим модел?

```vim
command! -nargs=1 -complete=custom,s:CompleteRailsModels
      \ Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  exe 'edit app/models/'.a:model_name.'.rb'
endfunction

function! s:CompleteRailsModels(ArgLead, CmdLine, CursorPos)
  let names = []

  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = file
    let name = substitute(name, '^app/models/', '', '')
    let name = substitute(name, '\.rb$', '', '')

    call add(names, name)
  endfor

  return join(names, "\n")
endfunction
```

---

# Как да намерим модел?

* Забележете, няма нужда да филтрираме -- връщаме опциите разделени с нов ред, Vim ще се оправи
--
* Ако използваме `customlist`, *тогава* вече трябва "на ръка" да филтрираме с `ArgLead` параметъра и да върнем *точните* completion резултати.
    * Но това дава повече контрол -- може да ги fuzzy-find-нем или сортираме по друг начин
--
* За статични completion ключове, нещо толкова просто може да свърши работа:

```vim
let g:global_hash = { 'command1': { ... some data ... }, ... }

function! s:CompletionFunction(argument_lead, command_line, cursor_position)
  return join(sort(keys(g:global_hash)), "\n")
endfunction
```

---

# Как да намерим контролер?

Буквално по същия начин, само че вместо "models" ползваме "controllers".

--

Формулата е толкова ясна, че Tim Pope я извлича в плъгин: <https://github.com/tpope/vim-projectionist>

---

# Side note: защо не fuzzy finding?

* Fuzzy finding изисква визуален feedback, докато `:Еmo<tab> so<tab>` се запомня в muscle memory
--
* Fuzzy finding изисква повече контекст, за да се drill down-не, особено за големи проекти. Има неизбежен шум от това, че търсите некатегоризирани символи
--
* Fuzzy finding *може* да е ефективен/удобен за непознати проекти, но не мисля, че помага да опознаеш проекта, за това използвам дърво, докато го науча и си направя projections
--
* Your mileage may vary, всички мозъци са различни, правете каквото ви е удобно
    * Не забравяйте, че не е нужно да ползвате *един* метод
    * `:FuzzyFrontend`/`:FuzzyBackend`?
    * `:FuzzyRuby`/`:FuzzyJavascript`?
    * `:FuzzyMigrations`?

---

# Как да намерим factory?

... Следващия път

---

# Следващия път

* Как да дефинираме команди и т.н. per project?
--
* Insert-mode completion
--
* Ctags
--
* Gf, textprops
--
* Организация на кода в плъгин
