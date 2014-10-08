#/bin/bash

set -o emacs

# set editing-mode vi
# bind -m vi-insert “\C-l”:clear-screen

function getRoxVimrcFile(){
	local roxVimrc
	read -d "" roxVimrc <<-EOFVIMRC

		" file tab switching 
		nmap te  :tabedit 
		nmap tn  :tabn<Enter>
		nmap tp  :tabN<Enter>
		nmap <S-l> :tabn<Enter>
		nmap <S-h> :tabN<Enter>

		" file tab highlighting
		hi TabLineSel      term=bold cterm=bold
		hi TabLine         term=underline cterm=underline ctermfg=0 ctermbg=7
		hi TabLineFill     term=reverse cterm=reverse

		" folding
		set foldenable
		set foldmethod=syntax
		set foldlevel=100
		"autocmd BufNewFile,BufRead *.cpp,*.c,*.h,*.hpp  set foldmethod=syntax

		" indentation
		set tabstop=4
		set softtabstop=4
		set shiftwidth=4
		set noexpandtab

		imap <C-V> <Esc>lp

EOFVIMRC

	local roxVimrcFile=$(echo "/tmp/roxma_vimrc_$(whoami)" | sed 's/[^[:alpha:]/]//g')
	echo "$roxVimrc" > "$roxVimrcFile"
	echo "$roxVimrcFile"
}

# alias vim='$(whereis -b vim | awk  '"'"'{print $2}'"'"') -S $(getRoxVimrcFile)'
alias rvim='vim -S $(getRoxVimrcFile)'

function cdl(){
	cd `readlink -f $1` 
}


# for ctags
#   for example: make_print_include_path_for_ctags make all
function make_print_include_path_for_ctags(){
	# print make command | filter compiling command | filter include options | filter include path
	local includePath=$( $@ --just-print | grep -P '^(gcc|g\+\+)' | grep -ohP '\s\-I\s*[\S]+'  | sed "s/^\s\-I//" )
		# The following is not a strict filter, but OK for ctags
	# local defaultPath=$( g++ -E -x c++ - -v < /dev/null 2>&1 | grep -ohP '^\s\/\S+' )
		local defaultPath=""
	local allPath="${includePath} ${defaultpath}"
	echo $(for p in $allPath ; do echo "$(readlink -f $p)" ; done) | xargs -n1 | sort -u | xargs
}


# usage: 
#   for ((i=1; i<=10; i++)); do echo $i>>log1.log; sleep 3; done &
#   for ((i=1; i<=10; i++)); do echo $i>>log2.log; sleep 3; done &
#   tails *.log
# author: roxma
# function tails(){
# 	local files=$@
# 
# 	# subScript to trap signal
# 	local subScript='
# 
# 	thisScript=$1
# 
# 	trap '"'"'rm -f $fifoName $thisScript; echo tails exit'"'"' EXIT 
# 
# 	fifoName=""
# 	tmpName=/tmp/tails_fifo_$$
# 	mkfifo $tmpName
# 	if [ $? -eq 0 ]; then
# 		fifoName=$tmpName
# 	fi
# 	if [ "$fifoName" == "" ]; then
# 		echo "cannot create named pipe" 1>&2
# 		exit -1
# 	fi
# 	
# 	for file in '"$files"'
# 	do
# 		echo "listen $file"
# 		escapedFile=$(echo $file | sed -e '"'"'s/[\/&]/\\&/g'"'"')
# 		tail --pid=$$ -f $file | sed "s/^/$escapedFile# /g" &
# 	done
# 	
# 	while true; do cat $fifoName; done 
# 	'
# 
# 	local scriptFile=/tmp/tails_$$.sh
# 	echo "$subScript" > $scriptFile
# 	chmod 755 $scriptFile
# 	/bin/bash $scriptFile $scriptFile
# }
