---
title: Runtimepath
author: Андрей Радев
speaker: Андрей Радев
date: 23 март 2023
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

Административни (kind of) неща

* Упражнение 16 с completion: https://vim-fmi.bg/tasks/17
* `:set t_Co=256` или `:set termguicolors`

---

# Преговор

* marks
--
* малко Vimscript: разместване на прозорци
--
* Netrw
--
* Буфери
--
* args и опериране по много файлове наведнъж
--
* Range-ове на команди
--
* Начални стъпки в search-and-replace: substitute, vimgrep

---

# Да си направим `:Grep`

```vim
command! Grep call Grep(<q-args>)
```

---

# Какво научихме?

* `:help command-nargs`
* `:help command-range`
* `scriptversion 4`
* `:help getpos()` и кога изобщо не ни трябва
* `:help gv` -- ужасно удобно
* `defer`
* `grepprg`, `grepformat` (`:help errorformat`)
* `rg --vimgrep`, което можете да си инсталирате [с тези инструкции](https://github.com/BurntSushi/ripgrep#installation)

И още доста други, за по-нататък

---

# Време е за ~/.vim

* За да извикваме отделни команди, `:!command`
    * Примерно, `:!mkdir -p ~/.vim/colors`
    * `:silent !mkdir -p ~/.vim/colors` няма да изчака да натиснете "enter", но няма и да redraw-не екрана (`:help :!` за информация. Може да си пакетирате silent + redraw в обща команда?)
--
* За да "паузираме" Vim и да излезем в шела, `:shell`
    * Под gvim на windows, това ще отвори `cmd`
    * Ако искате powershell, `:set shell=powershell` (`:help powershell`)
--
* Има и `:terminal`, което ще отвори шел в нов прозорец (и на което така и не свикнах)
* За terminal mode -- по-нататък (когато го разуча), но си има `:help terminal`
--
* Под Neovim `:terminal` има различно поведение, но не съм сигурен за всички разлики
    * Пример: `:terminal ++curwin` не работи под Neovim (но има плъгини)
    * Пример: `:edit term://htop` работи под Neovim, не под Vim

---

# Време е за ~/.vim: Цветове

* `:set t_Co=256` / `:set termguicolors`
--
* `~/.vim/colors/andrew-light.vim`
* `colorscheme andrew-light`
--
* `:set fillchars=stl:─,stlnc:─,vert:│`
* Aside: `:digraphs`
--
* Можем и спокойно да преместим `~/.vimrc` към `~/.vim/vimrc`
* (Впрочем: `~` -> `$HOME`: `/home/andrew`, `C:\Users\Andrew`)

---

# ~/.vim: Още директории

* `plugin`
* `autoload`

---

# Идея: Extract

```vim
command! -range -nargs=1 -complete=file Extract call Extract(<line1>, <line2>, <q-args>)

function Extract(start_line, end_line, filename)
  echomsg string([a:start_line, a:end_line, a:filename])

  " Записваме съдържанието в дадения файл
  " Изтриваме го от буфера
  " Отваряме го в split
endfunction
```

---

# Aside: modelines

`:help modeline`

* Първите 5 реда по default, може да се смени с `:help 'modelines'`
--
* `:set modelines=0` напълно го спира
--
* `vim: foldmethod=indent relativenumber`

---

# Aside: folding

`:help folding`

* `:set foldmethod=indent` -- прост, често върши добра работа
--
* `:set foldmethod=syntax` -- стига да е дефиниран за filetype-а
--
* `:set foldmethod=marker` -- `{{{` започва fold, `}}}` го затваря. Или `{{{1`, без нужда от затварящ.
* `zf{motion}` добавя маркери, `zd` трие заобикалящите
--
* `:set foldmethod=manual` -- На ръка, помни се къде е pin-нат
* `zf{motion}` създава fold, `zd` го трие

---

# Aside: folding

* `zo`, `zc` -- отваря, затваря
* `zО`, `zC` -- отваря, затваря рекурсивно
--
* `za`, `zA` -- toggle
--
* `zR` -- просто отваря всичко
--
* И още много други, но няма да задълбаваме

---

# Autoload

Функция с име `foo#bar#baz()` може да се извика и Vim ще потърси файл `autoload/foo/bar.vim` някъде в `runtimepath` и ако го намери, ще го source-не.
--
Там обикновено искате да ви е повечето код.

---

# Runtimepath

* `:set runtimepath`
* В код, може да ползваме `&runtimepath`, често `&rtp`

---

# Най-простите плъгини

No magic:

```vim
for dir in split(glob('~/.vim/bundle/*'), "\n")
  exe 'set runtimepath+=' .. dir
endfor

for dir in split(glob('~/.vim/miniplugins/*'), "\n")
  exe 'set runtimepath+=' .. dir
endfor
```

---

# Pathogen

Almost no magic:

```vim
call pathogen#infect()
call pathogen#helptags() " опционално
```

Отивате във <https://github.com/tpope/vim-pathogen> и директно вземате `autoload/pathogen.vim`.
--
Другия път повече за плъгини и git
