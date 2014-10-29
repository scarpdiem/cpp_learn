{

	# vim 
	unalias vim 2>/dev/null
	alias vim="$(which vim | awk '{print $NF}') -S \"$(getRoxVimrcFile)\" -p"
	if [[ -d $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/.local_vim ]]; then
		alias vim="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/.local_vim/bin/vim -S \"$(getRoxVimrcFile)\" -p"
	fi

	# ctags
	unalias ctags 2>/dev/null
	alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"


}
