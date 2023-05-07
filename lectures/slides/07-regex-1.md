---
title: Регекси 1
author: Андрей Радев
speaker: Андрей Радев
date: 20 април 2023
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

* Може да си конфигурирате vimrc-та в сайта: <https://vim-fmi.bg/profile/vimrc/edit>
* Може да пускате решения на стари задачи: <https://vim-fmi.bg/free_tasks>

---

# Преговор

* Аутокоманди
--
* Filetypes
--
* Statusline
--
* Vimscript в (повече) детайли

---

# Регекси: история

* "Регекси" (regex) е нещо като "Регулярни изрази" (regular expressions) но повече
--
* PCRE (Perl-compatible regular expressions) -- най-популярни
--
* За тестване и експериментиране, примерно:
    * <https://regex101.com/>
    * <https://regexr.com/>
    * (не ни вършат работа за Vim, обаче 🥲)
--
* Регексите на Vim идват от ed, което вдъхновява sed и Perl, но Perl и Vim си вървят в различни (но близки) посоки

---

# Регекси: преди да започнем

Пълен reference, от синтактична конструкция до списък на pattern-ите, може да намерите във `:help pattern.txt`. Не е нужно да ги помните, винаги може да намерите цялата информация от `^` до `$`.

Списъка на индивидуалните специални символи започва от `:help pattern-overview`.

Целта на лекцията е по-скоро да разберете механизмите и да ви дам акъл кои неща са полезни и кои не чак толкова (както всички лекции, I guess). С времето ще изградите интуиция.

---

# Регекси: основни неща

Търсим шаблони с `/<pattern>`, пример:

```
foo
fooooo
fo
f
foo+bar
foo*bar
foobar
```

* `/foo` -- буквално поредицата от символи "foo"
    * повечето азбучни символи просто пасват as-is
--
* `/fo\+` -- буквата "f" последвана от поне едно "o", колкото се може повече пъти
* `/foo+` -- "foo" последвано от "+"
    * специални символи обикновено са префикснати с `\`
--
* `/fo*` -- буквата "f" последвана от "o", нула или повече пъти
* `/foo\*` -- буквата "f" последвана от "\*"
    * някои символи са специални и `\` ги прави нормални

---

# Регекси: основни неща

Мапинга `*` добавя "word boundaries":

* "foo\&gt;" -- Думата `foo`, но само ако е последвана от не-дума -- `foo+bar` да, `foobar` не.
* "\&lt;foo" -- Думата `foo`, но само ако е предшествана от не-дума -- `bar+foo` да, `barfoo` не.
* "\&lt;foo\&gt;" -- Думата `foo`, стига да не е част от друга дума

---

# Регекси: Основни неща

* `.` -- какъвто и да символ, точно един
    * примерно `example.com` ще мачне `example.com`, но също така `example!com`
--
* `.*` -- каквито и да е символи, колкото се може повече, може и да няма никакви.
    * `".*"` ще хване всичко в двойни кавички. Но е greedy -- ще match-не колкото се може повече
--
* `.\+` -- също greedy, поне един символ
--
* `.\=` -- също greedy, 0 или 1 символа (т.е. този един символ ще мачне ако го има)
https://
    * Пример: `https\=://`
--
    * `\?` прави същото: `https\?://` (за съвместимост със PCRE)

---

# Регекси: non-greedy варианти

`:help /\{` -- greedy

```
\{n,m}  n to m          as many as possible
\{n}    n               exactly
\{n,}   at least n      as many as possible
\{,m}   0 to m          as many as possible
\{}     0 or more       as many as possible (same as *)
```

--

`:help /\{-` -- non-greedy

```
\{-n,m} n to m          as few as possible
\{-n}   n               exactly
\{-n,}  at least n      as few as possible
\{-,m}  0 to m          as few as possible
\{-}    0 or more       as few as possible
```

---

# Регекси: non-greedy варианти

* `.\{-}` -- non-greedy варианта на `.*`
    * `/".\{-}"` ще мачне низове малко по-адекватно
* `.\{-1,}` -- поне един, може и повече -- non-greedy `\+` (едва ли ще го ползвате много)

---

# Регекси: групиране

* `\(foo\)\+` -- цялата група между `\(` и `\)` бива афектирана от `\+`.
--
* `\%(foo\)\+` -- същото, но групата не се capture-ва като subexpression, повече за това после
--
* `[abc]` -- всички символи между `[` и `]` пасват. `[abc]\+` ще мачне `abc`, `bca`, `aaaccbbabb`, etc
    * `:help /[]`
--
* `[a-zA-Z]` -- всички букви, еквивалентно на `\a`
* `[0-9]` -- всички цифри, еквивалентно на `\d`
* `[0-9A-Za-z_]` -- "word characters", еквивалентно на `\w`
* `:help \d` и четете надолу
--
* `[а-я]` -- работи
--
* `[^abc]` -- всичко, което *не е* в скобките мачва. T.e. `[^0-9]` са не-цифри
* `[abc^]` -- a, b, c, ^

---

# Регекси: специални класове от символи

`:help /\i`

* `\k` -- буква от "ключова дума", зависи от съдържанието на `:help 'iskeyword'`
--
    * Ще срещате това често. Примерно `let \k\+ =` -- Дефиниция на променлива
    * (Или може би `\<let\s\+\k\+\s*=`, но да не изпадаме в детайли)
--
    * `iskeyword` се уважава за тонове неща: "expand('<cword>')", "\\<word\>", какво ли още не. Не е добра идея да го променяте (но може да пробвате и да видите какво ще се счупи)
--
* `\f` -- "символ от файл", зависи от съдържанието на `:help 'isfname'`
    * Използва се за `gf`, но по-скоро няма да разчитаме на него много
--
* `\i` -- буква от "идентификатор", зависи от съдържанието на `:help 'isident'`
* `\p` -- "видим символ", зависи от съдържанието на `:help 'isprint'`. Примерно табове, интервали, ctrl-комбинации не влизат тук.
    * Тези два не съм ги използвал никога, basically

---

# Регекси: специални класове от символи

В рамките на `[]`, за голяма досада, character класове като `\d` или `\k` не работят. Но имаме `[:digit:]` и `[:keyword:]`.

* Числа или удивителна може да е `\(\d\|!\)` или `[[:digit:]!]`
* Keyword character или тиренце: `\(\k\|-\)` или `[[:keyword:]-]`

Списъка започва от `:help [:alnum:]`

---

# Регекси: whitespace

* Интервала си е нормален символ, така че `foo *` означава "foo" последвано от ` *`, тоест 0 или повече интервали. Внимавайте с модификаторите!
--
* Мега често се използва `\s`, което е интервал или таб. Така хваща всякаква индентация или подравняване.
--
* Ако искаме да хванем нов ред, може да ползваме `\n`, което като регекс *би трябвало* да работи и на windows.
--
* Комбиниран вариант е `\_s`, което е "whitespace включително нов ред".
* Подчертавката модифицира *всеки* character class да добави "нов ред". Примерно `\_.` е какъвто и да е символ, включително нов ред.
--
* В тоя ред на мисли, `^` мачва начало на ред, `$` мачва край. `^\s*$` ще мачне цял ред, който съдържа само интервали или табове, или нищо.

---

# Регекси: backreference

Веднъж като сме групирали нещо с `\(\)`, можем да го реферираме като `\1`, втората такава група е `\2`, etc. (Групата `\0` е целия match, което е единствено полезно за substitution-и после.) В документацията това се нарича "subexpression", другате "submatch" или "capture group".

--

За да мачнем само многоредовия низ, `\(\u\+\)\_.*\1`:

```
code = <<~EOF
  example_text
EOF

other_code = <<~SQL
  select * from users
SQL
```

--

- `\(\u\+\)` -- uppercase символи, поне един, колкото се може повече
- `\_.*` каквото и да е, включително нов ред
- `\1` същия низ, хванат в първата група

---

# Регекси: branching

`:help pattern` -- `\|`, `\&`

* `foo\|bar` -- или "foo", или "bar", и двете мачват.
--
* `foo\|barbaz` -- "foo" или "barbaz"
* `\(foo\|bar\)baz` -- "foo" или "bar", последвано от "baz"
--
* `\&` е "обратното" на `\|`, и двата регекса трябва да мачват на едно и също място
--
* От документацията: `".*Peter\&.*Bob" matches in a line containing both "Peter" and "Bob"`
--
* ... вероятно няма да го ползвате, обикновено ще има по-гъвкави начини да постигнете това

---

# Magic

`:help magic`

* Вероятния източник на името на настройката: <http://www.jargon.net/jargonfile/a/AStoryAboutMagic.html>

---

# Magic: very magic

Very magic mode: Започва със `\v`

* Стандартен ("magic") регекс: `\(foo\|bar\)baz[!?]\=` -- "foo" или "bar", последвано от baz и опционална пунктуация
--
* Very magic: `\v(foo|bar)baz[!?]=`
--

```
Use of "\v" means that after it, all ASCII characters except '0'-'9', 'a'-'z',
    'A'-'Z' and '_' have special meaning: "very magic"
```

---

# Magic: very magic

* Предимство: ако пишете някакъв по-сложен регекс, може да е доста по-четим и лесен за писане
* Недостатък: ако търсите нещо просто, може да ви спъне, примерно
    * `\vfunction_call(` ще гръмне
    * `\vlet \k+ =` няма да мачне `=` накрая

---

# Magic: very NOmagic

Very nomagic mode: Започва със `\V`

```
Use of "\V" means that after it, only a backslash and the terminating
character (usually / or ?) have special meaning: "very nomagic"
```

--

* Ако имаме някакъв буквален текст, това е супер начин да се подсигурим, че няма да има специални символи в него.
--

```vim
let user_input = input("Search for a string: ")
exe '/\V' .. escape(user_input, '/\')
```

--

или,

```vim
let user_input = input("Search for a string: ")
call search('\V' .. escape(user_input, '\'))
```

---

# Magic: nomagic

`:help 'nomagic'` -- просто не го използвайте. Като "very nomagic", но `$` е специален символ.

---

# Magic: обобщение

* Magic mode (`\m`) -- default, комбинация от специални и не-специални символи
* Nomagic mode (`\M`) -- игнорирайте
--
* Very magic mode (`\v`) -- по-лесен начин да въвеждате по-сложни изрази.
    * Някои хора си правят `nnoremap / /\v`, но според мен не си заслужава
* Very nomagic mode (`\V`) -- за вход от потребителя, който трябва да се третира буквално
--
* Моята препоръка -- научете си и си ползвайте default-ния magic mode, имайте very nomagic предвид, когато боравите с литерални низове.
* (А ако използвате very magic за удобство, символите са същите anyway, просто с по-малко наклонени черти)
* (Може да си направите мапинг, който маха или слага `\v`... може би ще си поиграем по-нататък)

---

# Syntax highlighting

--
`:help syn-define`, доста четене. Централните три команди:

--
```vim
syntax keyword {name} <keyword1> <keyword2> ...
```

само една дума, и то само такава, чиито символи са във `'iskeyword'` настройката.
--
```vim
syntax match {name} /<regex>/
```

Регекса може да е ограден в каквито и да е разделители, не само `//`
--
```vim
syntax region {name} start=/<regex>/ end=/<regex>/
```

опционално може да се подаде и `skip=/<regex>/`

---

# Примери от документацията:

* `syntax keyword`:

    ```vim
    syntax keyword Type int long char
    syntax keyword vimCommand ab[breviate] n[ext]`
    ```
--

* `syntax match`:

    ```vim
    syntax match Character /'.'/hs=s+1,he=e-1
    ```
    * Какво е `hs=...`? Вижте `:help syn-pattern-offset`
--

* `syntax region`:

    ```vim
    syntax region String start=+"+ skip=+\\"+ end=+"+
    ```
    * Забележете: delimiter-ите могат да са какъвто и да е един символ

---

# Примери от `$VIMRUNTIME/syntax/javascript.vim`

```vim
syntax keyword javaScriptCommentTodo TODO FIXME XXX TBD contained

syntax match javaScriptLineComment "\/\/.*" contains=@Spell,javaScriptCommentTodo
syntax region javaScriptComment start="/\*" end="\*/" contains=@Spell,javaScriptCommentTodo

syntax region javaScriptEmbed start=+${+ end=+}+ contains=@javaScriptEmbededExpr
```

---

# Syntax debugging: `synID`

Синтактичната група под курсора:

```vim
let syn_id = synID(line('.'), col('.'), 0)
" (последния аргумент може да е 1, ако искаме да игнорираме прозрачни групи)

let syn_name = synIDattr(syn_id, "name")
" Примерно: vimComment
```
--

Всички stack-нати групи на курсора:

```vim
let syn_ids = synstack(line('.'), col('.'))
let syn_names = mapnew(syn_ids, {_, id -> synIDattr(id, "name") })
" { x, y -> ... } -- анонимна функция, която приема два параметъра, x и y

" Това също работи;
let syn_names = mapnew(syn_ids, 'synIDattr(v:val, "name")')
```

---

# Syncing

Откъде се почва да се highlight-ва?

--
* По default: от най-горния видим ред. Всичко се кешира агресивно, така че след първия highlight, промени по средата на буфера са тривиални
    * Това може да се счупи ако най-горния ред е по средата на многоредов коментар примерно
    * Почти никой filetype не оставя този default, обикновено се ползва `minlines`
--
* Най-сигурния начин: `syn sync fromstart` ще накара Vim да започне от началото на буфера и да highlight-ва оттам. Това обаче scale-ва с размера на буфера. Пак е кеширано, така че реално това ще е бавно само първия път.
    * Никой filetype не прави това :). Но може да го направим на ръка в случай на нужда
--
* Руби използва `syn sync minlines=500`, повечето вградени езици ползват между 50 и 1000 реда. Това означава "започни от поне толкова реда нагоре" при инициализация.
    * `syn sync maxlines=` -- ако искаме да ограничим броя редове нагоре защото сме на бавна машина.
    * Пак, всичко е силно кеширано и единственото забавяне е при първо отваряне
--
* `syn sync match` - по-сложен метод, указва синтактична група, която се знае, че започва или завършва многоредов match. `:help syn-sync-fourth`. Проверете `syn sync` във vimscript файл примерно.

---

# Syncing

Откъде се почва да се highlight-ва?

* Всичко това на вас вероятно няма да ви трябва. Но може да го прочетете от интерес как работи и може да грепнете из vim runtime files за низа "syn sync" и да разгледате как се правят нещата в различни filetypes.
* In general, syntax highlighting-a Just Works. Но ако се озовете във файл, който е highlight-нат като низ или коментар, ударете един `syn sync fromstart`, или си го направете на мапинг.

---

# Highlighting

Просто връзваме filetype-специфичните групи с "глобалните":

```vim
highlight link javaScriptComment Comment
" За кратко:
hi link javaScriptComment Comment
" Ако някой реши да линкне *преди* това:
hi default link javaScriptComment Comment
```

Списък на всички стандартни групи, които не са filetype-specific: `:help highlight-groups`. Стандартните конвенции като "Comment", "String" etc се гледат от някоя цветова схема.

Повече на следващата лекция.

---

# Highlighting: Images

Няма магия, просто усърдие: <https://github.com/tpope/vim-afterimage>

---

# Substitute

Виждали сме го и преди: `:s/{pattern}/{string}/[flags]`

* `%s/foo/bar/g` -- замести в целия буфер "foo" със "bar", "g" означава всички match-ове на реда
--
* `3,4s/foo/bar/g` -- замести само от редове 3 до 4
--
* `s/foo/bar/g` -- замести само на текущия ред

---

# Substitute: Backreferences

Разменяме първата и втората capture-ната група:

```vim
%s/"\(.*\)" => "\(.*\)"/\2 => \1/g
```

---

# Substitute: Backreferences

Uppercase-ваме стойността в кавичките:

```vim
%s/=> "\zs.*\ze"/\=toupper(submatch(0))/g
```

* `\zs` и `\ze` не са необходими, но са мега удобен трик
* `:help \zs`
* `:help sub-replace-expression`
--

```vim
%s/=> "\zs.*\ze"/\U\0/g
```
също работи без expression register -- `:help sub-replace-special`

---

# Substitute: Backreferences

Разбива реда -- *не* `\n`

```vim
%s/=> ".*"/\r\0/g
```

---

# Substitute: Трикове

* `s//<replacement>/g` -- замества последното нещо в search history
* `s/<pattern>/~/g` -- замества pattern-а със последния replacement
* `s/<pattern>/<replacement>/&` -- Същите флагове като предния substitution
--
* `s/<pattern>/<substitution>/gc` -- "c" флага пита за confirmation, "i" игнорира case.
    * `:help :s_flags` за доста други

---

# Global

```vim
g/<pattern>/<cmd>
```

"Командата" е каквато и да е команда в нормален режим. Забележете че за разлика от `:substitute`, без аргументи се прилага върху целия файл (затова е "global"). Но пак приема range.

Често се използва "p", кратко от "print"

* `g/^\s*:\k\+/p` -- печата всички редове, които започват с `:` последвано от keyword characters
--
* `g//d` -- изтрива (командата е :delete) всички редове, които пасват на последния search/substitute/global etc.
--
* `g//normal! >>` -- индентира всички мачващи редове
--
* `g!//normal! >>` -- индентира всички редове, които *не* мачват
* `v//normal! >>` -- същото

---

# Как да упражнявате регекси?

* Ще разглеждаме плъгини, ще ги ползваме доста, ще имате шанс
--
* В идващите упражнения съм подготвил `:substitute`-friendly задачки
--
* Може да разгледате в детайли [javascript syntax файла](https://github.com/vim/vim/blob/be9624eb47ff4db4f068c65ad9cd37b14d1818a8/runtime/syntax/javascript.vim)
--
* Ако сте особено смели, може да разгледате [ruby syntax файла](https://github.com/vim/vim/blob/be9624eb47ff4db4f068c65ad9cd37b14d1818a8/runtime/syntax/ruby.vim)... Но не сме говорили за доста от инструментите, които се ползват там (negative lookbehind примерно)
--
* Може да си направите syntax highlighting на собствен filetype, примерно `*.notes`
