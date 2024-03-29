## gatherum

a omnium-gatherum of norns ideas / single purpose scripts. 

this is a collection of scripts I've generated during my musical journey with norns + SuperCollider. they are not quite "fully formed", but all of them work well for their intended purpose. I continue to find these useful for my own learning and/or for a specific musical purpose. 

current scripts:

- <kbd>br</kbd>: sample-based noisy chaotic breakbeat created using the `Breakcore` UGen. ([demo](https://www.instagram.com/p/COsjGK_hjZ7/?utm_source=ig_web_copy_link))
- <kbd>brbr</kbd>: sample-based chaotic breakbeat engine using my sample engine + `Task` (possibly less noisy than `br`) ([demo](https://www.instagram.com/p/CO6FYwGhEKz/))
- <kbd>brbrbr</kbd>: live-input breakcore engine (add fx maybe too?) 
- <kbd>kalimba</kbd>: a kalimba follower for Am-tuned kalimba

use these as-is. or play with them. change them. install them, delete them. break them. unbreak them. make them something else. make them your own. the lua scripts are all small (<100 lines) and straightforward. the engines may be interesting starting points or ending points for something. 

### requirements 

- norns

### ~~documentation~~ 


the code serves as documentation, and I can fill in the gaps by answering questions.


#### `live.lua`

this is a live coding foundation, using maiden + norns scripts as the code.

lines from a norns script can be quickly and easily run using vim.

to use with vim, first download wscat - a utility for piping commands to a websocket server (maiden).

```
wget https://github.com/schollz/wscat/releases/download/binaries/wscat
chmod +x wscat
sudo mv wscat /usr/local/bin/
```

then you can edit your `.vimrc` file to include these lines which will automatically run
the current selected line when you press <kbd>ctl</kbd>+<kbd>c</kbd>:

```vim
set underline
nnoremap <C-c> <esc>:silent.w !wscat<enter>
inoremap <C-c> <esc>:silent.w !wscat<enter>i
```

now whenever you use the key combo <kbd>ctl</kbd>+<kbd>c</kbd> it will send the current line in vim into maiden!


### download

```
;install https://github.com/schollz/gatherum
```

make sure to restart, as there are several engines here that require re-compiling.

### license

MIT
