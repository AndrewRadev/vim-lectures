---
title: Neovim
author: Стефан Кънев
speaker: Стефан Кънев
date: 11 май 2023
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

Слайдовете са кратко обобщение от Андрей, гледайте видеото за истината, цялата истина, или поне 30% от нея

---

# Neovim vs Vim

* Донякъде религиозен проблем
* Започва се с лигатури в шрифтовете, остава се за скачащи курсори
* Началото на Neovim -- patch за background jobs, отнема твърде много време, човека решава, че ще си направи собствен форк
* Евентуално, Neovim става добър testbed за нови функционалности и тук-таме features пътуват и към Vim

---

# Neovim: причини

* Lua
* LSP
* TreeSitter
* Community

---

# Neovim: плъгини/инструменти

* Key explorer, чийто код е в демото: <https://github.com/skanev/key-explorer>
* Telescope, разширяем плъгин на lua: <https://github.com/nvim-telescope/telescope.nvim>
* Firenvim, за ембедване на Neovim в сайтове: <https://github.com/glacambre/firenvim>
* Графичен UI със скачащи курсори: <https://neovide.dev/>
    * Защо графичен UI? Някои клавишни комбинации, примерно Cmd, Alt, не работят в терминала. `<c-i>` е еквивалентно на `<tab>`, разни такива неща.

---

# Lua

* "Най-глупавите моменти" и някои по-малко глупави: <https://learnxinyminutes.com/docs/lua/>
* Често използван за конфигурация или скриптиране:
    * https://awesomewm.org/
    * https://wezfurlong.org/wezterm/index.html
    * Redis, Postgresql, World of Warcraft...

---

# Стефан

* Още Vim-ски и други програмистки видеа: https://www.youtube.com/@skanev
* Съвет: отивате и гледате чужди конфигурации, вземате какво ви харесва
    * https://github.com/skanev/dotfiles/
