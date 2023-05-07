---
title: Конфигурация, мапинги
author: Андрей Радев
speaker: Андрей Радев
date: 9 март 2023
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
}
</style>

# Административни неща

* Две упражнения са активни: <https://vim-fmi.bg/tasks>
* За инструкции, вижте guide-а: <https://vim-fmi.bg/guides/tasks>
* След крайния срок, почват ежедневно, от понеделник

---

# Упражнение 002

* Visual block mode
* `p`/`P`
* `r`
* Подаване на брой

---

# Първото `.vimrc`

* `:edit .vimrc` под Unix
* `:edit _vimrc` под Windows (макар че и `.vimrc` би трябвало да работи)
--
* `:help $MYVIMRC`
--
* `:help vimrc-intro`
* `:help defaults.vim`
* Навигация на `:help` -- `Ctrl-]`, `Ctrl-t`
* (Напомняне: `Ctrl-[` е еквивалентно на `<esc>`)

---

# Първи стъпки

Ще започнем от defaults, после ще ги разгледаме внимателно:

```vim
source $VIMRUNTIME/defaults.vim
```

---

# Отваряне на прозорци

`:help opening-window`

* `split <filename>`
* `vsplit <filename>`
--
* `vertical split <filename>`
* `vertical new`
--
* `leftabove vertical split <filename>`
* `rightbelow vertical split <filename>`
--
* `tab help`

---

# Навигация на прозорци

`:help window-move-cursor`

`Ctrl-w` клавиши

* `Ctrl-w` + `hjkl`
--
* `Ctrl-w` + `w` / `Ctrl-w`
--
* `Ctrl-w` + `+`
* `Ctrl-w` + `-`
* `Ctrl-w` + `>`
* `Ctrl-w` + `<`
* `Ctrl-w` + `=`
--
* Подаване на числа

---

# По-лесни мапинги

```vim
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-h> <c-w>h
map <c-l> <c-w>l
```

--

Аз лично използвам `g` като префикс за тези:

```vim
map gj <c-w>j
map gk <c-w>k
map gh <c-w>h
map gl <c-w>l
```

---

# Още мапинги

```vim
map J 5j
map K 5k
```

(Не за всеки: `J` и `K` имат съществуваща функционалност -- it's all a tradeoff.)

---

# "Поправяне" на j и k

```vim
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk
```

* "nore", "x"?
* `:help map`
* `:help map-modes`

---

# Специални символи

* `:help map-return` -- `<cr>` ("carriage return") е "натискане на Enter"
* `:help map-bar` -- `<bar>` или `\|`, `map a b | map c d` ще изпълни две отделни `map` команди
* `:help map-backslash` -- `<Bslash>`
* `:help map-comments` -- не може да слагате коментари след `map`-ове, because how would that even work?
* `:help key-notation` -- пълен списък

--

Модификатори:

* `<buffer>`
* `<silent>`
* `<unique>`
* `<expr>`

---

# "Изчистване" на J, K

```vim
nnoremap <silent> J 5gj
nnoremap <silent> K 5gk
xnoremap <silent> J 5gj
xnoremap <silent> K 5gk
```

---

# Бързо презареждане

```vim
nnoremap ! :source %<cr>
```

---

# Дребни удобства

`dd`, `cc`, `yy`, съответно:

```vim
nnoremap vv ^vg_
```

---

# Дребни удобства

`D`, `C`, съответно:

```vim
nnoremap Y y$
```

---

# Insert/Cmdline-mode

```vim
inoremap <C-p> <Esc>pa
cnoremap <C-p> <C-r>"
```

---

# Aside: Copy-pasting

Малко странно

* Копираме в регистър "a" със `"ay`
* Копираме в регистър "b" със `"by`
* ...
* Пействаме със `"<регистър>p`
--
* "Unnamed register" -- `"`. T.e. `y` е еквивалентно на `""y`

---

# Aside: Copy-pasting

Защо?

* 26 места за копиране :)
--
* append-ване в азбучните регистри
--
* Специални регистри. `:registers`
--
* На практика -- рядко ще го използвате за копи-пейст "на ръка"
--
* (от друга страна, има хора със всякакви workflows)
--
* **Макроси**

---

# Aside: Copy-pasting

* `set clipboard=unnamed` -- копи-пейства и в selection буфера (`"*`) (linux)
* `set clipboard=unnamedplus` -- копи-пейства и в clipboard-а (`"+`) (linux)
* Сложете `set clipboard=unnamed,unnamedplus` в конфига и не го мислете (но го знайте)

---

# Insert/Cmdline-mode

```vim
inoremap <C-p> <Esc>pa
cnoremap <C-p> <C-r>"
```

- Защо `<c-r>`? "register"
- Защо `<c-r>"`? unnamed register
- (aside: `<c-r> =`)

---

# Aside: Vimgolf

Питонски речници: <https://www.vimgolf.com/challenges/9v0062e3e96a000000000226>

---

# Базови настройки от defaults.vim

Твърде много, минете сами. Някои съвети обаче.

---

# wildmenu

Моето предпочитание -- търся уникални hit-ове:

```vim
set wildmenu
set wildmode=list:longest,full
```

Neovim default:

```vim
set wildmenu
set wildmode=full
set wildoptions=pum,tagfile
```

---

# mouse

Възможно е да влизате във visual mode с мишката. Може дори да е полезно понякога. Но е мега досадно като се ssh-нете. Това ще накара мишката да селектира неща в терминала, не във Vim:

```vim
set mouse=
```

Ваш избор 🤷

---

# Защото е мега досадно

```vim
set nobackup
set nowritebackup
set noswapfile
```

Или, вижте `:help 'backupdir'` и `:help 'directory'`

---

# set/unset/query

Булеви стойности

```vim
set number   " set-ва number
set nonumber " unset-ва number
set number?  " печата текущия state
set number&  " reset-ва до default
set number!  " toggle-ва
```

---

# set/unset/query

Списъци

```vim
set nrformats               " същото като :set nrformats?
set nrformats=bin,octal,hex " set-ва на конкретен списък от стойности
set nrformats-=octal        " маха стойности
set nrformats+=octal,alpha  " добавя стойности
```

`:help :set`

---

# Neovim: mostly the same

--

* Важно е да си създадете директориите описани в `:help vimrc`
* Не ви трябват syntax on, някои други неща -- проверете в `:help`
* `:checkhealth` -> `:help nvim-from-vim`
