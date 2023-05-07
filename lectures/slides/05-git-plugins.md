---
title: Git, плъгини
author: Андрей Радев
speaker: Андрей Радев
date: 30 март 2023
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

* 13ти-18ти април: Великден
* Без упражнения тези дни, без лекция на 13ти

---

# Преговор

* Grep команда
--
* Влизане в шела със `:sh`, `:terminal`, изпълняване на команди със `:!`
--
* Директория `~/.vim` със `colors`, `plugin`, `autoload`
--
* Modelines
--
* Folding
--
* Autoload
--
* Runtimepath и Pathogen

---

# Git

--
* Version control system: Правите си snapshot-и на кода
--
* Инсталация: https://git-scm.com/
--
* Vim в github: https://github.com/vim/vim

---

# Git

За домашна употреба

* `git init .` -- инициализира ново repo
--
* `git status` -- дава ни информация за текущото състояние
--
* `git add <file1> <file2>` -- добавя файлове за commit-ване ("stage"-ва ги)
* `git add --all`
--
* `git reset <file>` -- премахва файлове от списъка за commit-ване ("unstage"-ва ги)
* `git reset`
--
* `git commit` -- отваря редактор (vim, разбира се) със съобщение за писане
* `git commit -m "Commit message"`
* `git commit -v`
--
* Tim Pope описва добри съобщения: <https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html>

---

# Git

За домашна употреба

* `git diff`
* `git diff --stat`
* Бонус: `git diff | vim - -R`
--
* `git log`
* `git log --oneline`
--
* `git checkout <sha>` -- сменя на този конкретен commit

---

# Git

С други хора

* `git remote add origin git@github.com:AndrewRadev/vim-fmi-vimfiles.git`
* `git remote -v`
--
* `git push -u origin main` -- `-u`-то е нужно само първия път, оттам нататък:
* `git push` би трябвало да сработи
--
* `git pull`
* `git fetch` -- само събира промени от remote-а, но не ги прилага

---

# Git

С други хора, които не харесваме

* `git revert <sha>` -- създава нов commit, но не променя историята
--
* `git reset --hard <sha>` -- изцяло изчиства всякакво състояние до дадения commit
* `git reset --hard` -- изчиства всички не-commit-нати промени
--
* `git push --force`
* `git push --force-with-lease` -- по-учтиво, но просто проверява че текущия branch track-ва това, към което push-ваме
    * "The protection it offers over --force is ensuring that subsequent changes your work wasn’t based on aren’t clobbered"
--
* Не е предназначен за нормална употреба, а за фиксове. Важно е да *знаете*, че само вие мажете на тоя бранч.

---

# Git

Когато искаме да ремонтираме нещата

* `git reflog` -- всички състояния, дори и тези, които сме изтрили от дървото
* Не е гаранция -- `git prune` или `git gc` ще зачисти "висящи" състояния

---

# Git

За Vim плъгини

* Можем да теглим Vim плъгини от <https://www.vim.org/>
--
* Можем и чрез `git clone https://github.com/tpope/vim-surround`
--
* Или може би...
* `git submodule add https://github.com/tpope/vim-surround bundle/surround`
* `git submodule add git@github.com:AndrewRadev/undoquit.vim.git bundle/undoquit`

---

# Git submodules

* Малко са досадни. Не ги препоръчвам силно
* Но ако искате да си работите по плъгините...
* <https://git-scm.com/book/en/v2/Git-Tools-Submodules>
* Вероятно ще се наложи: `git config --global core.excludesfile ~/.gitignore`
--
* `git submodule sync` -- ако променим URL-а в `.gitmodules`
* `git@github` vs `https://github.com` -- write/read
--
* Хитър трик: `../undoquit.vim.git`
    * Ако клонирам репото през `https://github.com/AndrewRadev/vim-fmi-vimfiles`: `https://github.com/AndrewRadev/undoquit.vim.git`
    * Ако клонирам репото през `git@github.com:AndrewRadev/vim-fmi-vimfiles.git`: `git@github.com:AndrewRadev/undoquit.vim.git`
* (Ако не разбирате горното, не го мислете твърде много)

---

# Vim плъгини по лесния начин

vim-plug: <https://github.com/junegunn/vim-plug>

```vim
call plug#begin()
Plug 'tpope/vim-surround'
Plug 'AndrewRadev/undoquit.vim'
Plug 'AndrewRadev/andrews_nerdtree.vim'
Plug 'AndrewRadev/nerdtree'
Plug 'kana/vim-smartword'
Plug 'simnalamburt/vim-mundo'
call plug#end()
```

---

# Aside: lazy-loading

Undoquit и липсващата аутокоманда

--
* Накратко: недейте
--
* Надълго: дейте ако много искате, ама вероятно не си заслужава
* `vim --startuptime <file>`
--
* If you see something, say something:
    * https://github.com/DougBeney/pickachu/pull/12
    * https://github.com/craigemery/vim-autotag/pull/36


---

# Native "packages"

`:help packages`

* Намират се във `~/.vim/pack`
--
* *Не са* плъгини, а *колекции* от плъгини, организирани в `start` и `opt` директории
--

```
pack/foo/README.txt
pack/foo/start/foobar/plugin/foo.vim
pack/foo/start/foobar/syntax/some.vim
pack/foo/opt/foodebug/plugin/debugger.vim
```

--
* След като се зареди vimrc-то, всичко в `pack/foo/start` се добавя в runtimepath
* Всичко в `opt` си седи, зарежда се експлицитно с `packadd foodebug`

---

# Проблеми с packages

* Никой *actually* не прави "пакети". Това е несъвместимо с други package manager-и. Масово индивидуални плъгини се слагат в една директория просто като един "пакет".
--
* Плъгин се зарежда автоматично ако е в `start`, или може да се зареди ръчно ако е в `opt`, но двете не се комбинират
--
* (Но има workaround със `runtime START`, което все е нещо)
--
* Ако пишете документация за плъгини, това е супер досадно за обяснение
--
* Ако ползвате submodules, директориите са супер досадни за местене

---

# Предимства на packages пред pathogen

* 🤷
--
* Може би performance? Но на модерно SSD това не е проблем
--
* Може би single loading? Но всички плъгини масово използват `if !exists('g:loaded_<plugin-name>') | finish | endif`
--
* Стандартизацията на зареждането на плъгина с `:packadd` е смислена. Но това е само за `opt` плъгини, иначе пак се връщаме на хакове с `runtime`.
* Работи добре за вградените Vim плъгини
--
* In general, packages *работят*. Ако просто мятате неща в `pack/<whatever>/start`, това ще е ок. (Но и pathogen работи.)

---

# Long story short

* Ако искате лесен живот, [vim-plug](https://github.com/junegunn/vim-plug) е чудесен избор
--
* Ако сте ок да си играете със submodules и/или искате да си теглите zip файлчета с плъгини, [pathogen](https://github.com/tpope/vim-pathogen) работи перфектно
--
* Ако искате да използвате вградените механизми до максимума им, `:help packages`, или [minpac](https://github.com/k-takata/minpac), което ще ви тегли кода с git и ще го слага в `pack/` директорията.
--
* За neovim-специфични опции (сигурно) ще говорим по-нататък (но всички горни неща работят без проблеми)

---

# Aside: идея за проект

Напълно смислена идея е да си напишете собствен plugin manager със...

--
* Autocompletion/search на имена на проекти
--
* Scrape-ване на vim.org, или лесна инсталация от bitbucket, gitlab, неща с не-git version control...
--
* Проверка за ъпдейти с virtual text до entry-тата във vimrc-то
--
* Version/dependency management
--
* Blackjack etc...
--
* Не го *препоръчвам*, доста специфична идея е, просто е една идея
