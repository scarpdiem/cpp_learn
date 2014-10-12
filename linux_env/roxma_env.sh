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
		" autocmd BufNewFile,BufRead *.cpp,*.c,*.h,*.hpp  set foldmethod=syntax

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

# vim 
unalias vim 2>/dev/null
alias vim="$(which vim | awk '{print $NF}') -S \"$(getRoxVimrcFile)\""

# ctags
unalias ctags 2>/dev/null
alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"


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

	local lcAllBackup="$LC_ALL"
	export LC_ALL="${lcAllBackup/zh_CN/en_US}"

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

	export LC_ALL="$lcAllBackup"
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

function scpex(){

        read -p "password: " password

        local expectCmd='

        set timeout 10

        spawn scp '"$@"'
        expect {
                "*yes/no" { send "yes\r" }
                "*password" {
                        send "'"$password"'\r"
                        exp_continue
                }
        }
        '

        expect -c "$expectCmd"

}

# options:
#   -h host
#   -p port
#   -d data to be sendded
#   -f read data from file
#   -r wait until a response package is read
function udpsend(){
	
	local pythonCmd="\
#!/usr/bin/env python2
# -*- coding: utf-8 -*-

# This program send a udp packet and then exit

def Entry():

	# get opts and args
	import getopt, sys 
	if sys.platform == 'win32':  # write binary data to stdout
		import os, msvcrt
		msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)

	try:
		opts, args = getopt.getopt(sys.argv[1:], ':h:p:d:f:r')
	except getopt.GetoptError as err:
		# print help information and exit:
		sys.stderr.write(str(err)+'\n') # will print something like 'option -a not recognized'
		exit(2)

	content = ''
	host = ''
	port = 0
	waitResponse = False
	
	for o, a in opts:
		if o == '-h':
			host = a
		elif o == '-p':
			port = int(a)
		elif o == '-d':
			content = a
		elif o == '-f':
			fileName = a
			f = open(fileName, 'rb')
			content = f.read()
			f.close()
		elif o == '-r':
			waitResponse = True
	
	sys.stderr.write('options: %s\n' % opts)

	if host=='':
		raise Exception('host should be specified')
	if port == 0:
		raise Exception('port should be specified')

	address = (host,port)

	import socket
	udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sendCount = udp.sendto(content, address)

	sys.stderr.write( '%s bytes sended\n' % sendCount)

	if waitResponse:
		response, resAddr = udp.recvfrom(65536)
		sys.stdout.write(response)
		sys.stderr.write( '%s bytes recieved\n' % len(response))
		import pprint
		sys.stderr.write( pprint.pformat(response) + '\n')

	udp.close()
	 
	exit(0)

Entry()
"
	python -c "$pythonCmd" $@

}


