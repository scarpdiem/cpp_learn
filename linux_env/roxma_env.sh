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
		" set foldenable
		" set foldmethod=syntax
		" set foldlevel=100
		autocmd BufNewFile,BufRead *.cpp,*.c,*.h,*.hpp  set foldmethod=syntax

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

unalias vim 2>/dev/null
alias vim="$(which vim | awk '{print $NF}') --cmd \"source $(getRoxVimrcFile)\""
# alias rvim='vim -S $(getRoxVimrcFile)'

function cdl(){
	if [[ -L "$1" ]]
	then
		local absPath="$(readlink -f $1)"
		if [[ -f $absPath ]]
		then
			cd $(dirname $absPath)
		else
			cd $absPath
		fi
	else
		cd `readlink -f $1` 
	fi
}


# for ctags
#   for example: make_print_include_path_for_ctags make all
# author: roxma
function make_print_include_path_for_ctags(){
	# # The following is not a strict filter, but OK for ctags
	# # local defaultPath=$( g++ -E -x c++ - -v < /dev/null 2>&1 | grep -ohP '^\s\/\S+' )
	
	local dirStack=("$(readlink -f .)")

	# print the command, and read the output line by line
	$@ 2>&1 | while read -r line ; do

		# match string, for example:
		# make[1]: Entering directory `/home/roxma/test/src'
		if [[ "$line" =~ [[:alnum:]]*make[[:alnum:]]*\[[[:digit:]]+\]\:[[:blank:]](Entering)[[:blank:]]directory[[:blank:]]  ]]
		then
			# take /home/roxma/test/src from the matched string
			local dir=$(echo "$line" | grep -o -P "(?<=\`).*(?=')")
			# echo "$line"
			dirStack+=("$dir")
		fi

		# match string, for example:
		# make[1]: Leaving directory `/home/roxma/test/src'
		if [[ "$line" =~ [[:alnum:]]*make[[:alnum:]]*\[[[:digit:]]+\]\:[[:blank:]](Leaving)[[:blank:]]directory[[:blank:]]  ]]
		then
			# take /home/roxma/test/src from the matched string
			local dir=$(echo "$line" | grep -o -P "(?<=\`).*(?=')")
			# echo "$line"
			unset dirStack[${#dirStack[@]}-1]
		fi
		# local currentBase=
		
		local curDir="${dirStack[${#dirStack[@]}-1]}"
		# echo "$curDir"

		# if is compilation command
		if [[ "$line" =~ ^[[:blank:]]*(gcc|g\+\+) ]]
		then
			local incOptions=$(echo "$line" | grep -ohP '\s\-I\s*[\S]+'  | sed "s/^\s\-I//")
			for incOption in $incOptions
			do
				local incPath="$curDir/${incOption// }"
				incPath=`readlink -f $incPath`
				echo "$incPath"
			done
		fi
		
	done | xargs -n1 | sort -u | xargs # remove duplicate words
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
