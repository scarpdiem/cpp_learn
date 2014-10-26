

# vim 
unalias vim 2>/dev/null
alias vim="$(which vim | awk '{print $NF}') -c \"source $(getRoxVimrcFile)\" -p"

# ctags
unalias ctags 2>/dev/null
alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"
