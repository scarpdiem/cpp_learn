#!/bin/bash
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



			function udpsend(){
				echo "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMgojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLQoKIyBUaGlzIHBy
b2dyYW0gc2VuZCBhIHVkcCBwYWNrZXQgYW5kIHRoZW4gZXhpdAoKZGVmIEVudHJ5KCk6CgoJaW1w
b3J0IHN5cwoJaWYgbGVuKHN5cy5hcmd2KT09MToKCQlzeXMuc3RkZXJyLndyaXRlKCcnJwpvcHRp
b25zOgogIC1oIEhvc3QKICAtcCBQb3J0CiAgLWQgRGF0YSB0byBiZSBzZW5kZGVkLiBJZiB0aGlz
IG9wdGlvbiBpcyBub3QgcHJlc2VudCwgZGF0YSB3aWxsIGJlIHJlYWQgZnJvbSBzdGRpbi4gSWYg
eW91IHdhbnQgdG8gc2VuZCBiaW5hcnkgZGF0YSwgWW91IGNvdWxkIHVzZSB0aGUgcHJpbnRmIGNv
bW1hbmQsIGZvciBleGFtcGxlOgoJCXByaW50ZiAiXHgwMSIgfCB1ZHBzZW5kIC1oIGxvY2FsaG9z
dCAtcCAxMjM0NQogIC1yIFdhaXQgdW50aWwgYSByZXNwb25zZSBwYWNrYWdlIGlzIHJlYWQsIHRo
ZSByZWFkZWQgY29udGVudCB3aWxsIGJlIG91dHVwdCB0byBzdGRvdXQuIE5vdGUgdGhhdCB0aGUg
ZGVidWcgaW5mb3JtYXRpb24gb2YgdGhpcyB0b29sIGlzIG91dHB1dCB0byBzdGRlcnIuCicnJykK
CQlleGl0KDApCgoJIyBnZXQgb3B0cyBhbmQgYXJncwoJaW1wb3J0IGdldG9wdCwgc3lzIAoJaWYg
c3lzLnBsYXRmb3JtID09ICd3aW4zMic6ICAjIHdyaXRlIGJpbmFyeSBkYXRhIHRvIHN0ZG91dAoJ
CWltcG9ydCBvcywgbXN2Y3J0CgkJbXN2Y3J0LnNldG1vZGUoc3lzLnN0ZG91dC5maWxlbm8oKSwg
b3MuT19CSU5BUlkpCgoJdHJ5OgoJCW9wdHMsIGFyZ3MgPSBnZXRvcHQuZ2V0b3B0KHN5cy5hcmd2
WzE6XSwgJzpoOnA6ZDpmOnInKQoJZXhjZXB0IGdldG9wdC5HZXRvcHRFcnJvciBhcyBlcnI6CgkJ
IyBwcmludCBoZWxwIGluZm9ybWF0aW9uIGFuZCBleGl0OgoJCXN5cy5zdGRlcnIud3JpdGUoc3Ry
KGVycikrJ1xuJykgIyB3aWxsIHByaW50IHNvbWV0aGluZyBsaWtlICdvcHRpb24gLWEgbm90IHJl
Y29nbml6ZWQnCgkJZXhpdCgyKQoKCWNvbnRlbnQgPSAnJwoJaG9zdCA9ICcnCglwb3J0ID0gMAoJ
ZGF0YU9wdGlvblNldCA9IEZhbHNlCgl3YWl0UmVzcG9uc2UgPSBGYWxzZQoJCglmb3IgbywgYSBp
biBvcHRzOgoJCWlmIG8gPT0gJy1oJzoKCQkJaG9zdCA9IGEKCQllbGlmIG8gPT0gJy1wJzoKCQkJ
cG9ydCA9IGludChhKQoJCWVsaWYgbyA9PSAnLWQnOgoJCQlkYXRhT3B0aW9uU2V0ID0gVHJ1ZQoJ
CQljb250ZW50ID0gYQoJCWVsaWYgbyA9PSAnLWYnOgoJCQlmaWxlTmFtZSA9IGEKCQkJZiA9IG9w
ZW4oZmlsZU5hbWUsICdyYicpCgkJCWNvbnRlbnQgPSBmLnJlYWQoKQoJCQlmLmNsb3NlKCkKCQll
bGlmIG8gPT0gJy1yJzoKCQkJd2FpdFJlc3BvbnNlID0gVHJ1ZQoKCWlmIG5vdCBkYXRhT3B0aW9u
U2V0OgoJCWNvbnRlbnQgPSBzeXMuc3RkaW4ucmVhZCgpCgkKCXN5cy5zdGRlcnIud3JpdGUoJ29w
dGlvbnM6ICVzXG4nICUgb3B0cykKCglpZiBob3N0PT0nJzoKCQlyYWlzZSBFeGNlcHRpb24oJ2hv
c3Qgc2hvdWxkIGJlIHNwZWNpZmllZCcpCglpZiBwb3J0ID09IDA6CgkJcmFpc2UgRXhjZXB0aW9u
KCdwb3J0IHNob3VsZCBiZSBzcGVjaWZpZWQnKQoKCWFkZHJlc3MgPSAoaG9zdCxwb3J0KQoKCWlt
cG9ydCBzb2NrZXQKCXVkcCA9IHNvY2tldC5zb2NrZXQoc29ja2V0LkFGX0lORVQsIHNvY2tldC5T
T0NLX0RHUkFNKQoJc2VuZENvdW50ID0gdWRwLnNlbmR0byhjb250ZW50LCBhZGRyZXNzKQoKCXN5
cy5zdGRlcnIud3JpdGUoICclcyBieXRlcyBzZW5kZWRcbicgJSBzZW5kQ291bnQpCgoJaWYgd2Fp
dFJlc3BvbnNlOgoJCXJlc3BvbnNlLCByZXNBZGRyID0gdWRwLnJlY3Zmcm9tKDY1NTM2KQoJCXN5
cy5zdGRvdXQud3JpdGUocmVzcG9uc2UpCgkJc3lzLnN0ZGVyci53cml0ZSggJyVzIGJ5dGVzIHJl
Y2lldmVkOiAnICUgbGVuKHJlc3BvbnNlKSkKCQlpbXBvcnQgcHByaW50CgkJc3lzLnN0ZGVyci53
cml0ZSggcHByaW50LnBmb3JtYXQocmVzcG9uc2UpICsgJ1xuJykKCgl1ZHAuY2xvc2UoKQoJIAoJ
ZXhpdCgwKQoKRW50cnkoKQoK" | base64 -d | python - $@
			}
			

			function urldecode(){
				echo "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMgojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLQoKZGVmIEVudHJ5
KCk6CgkKCWZyb20gdXJsbGliIGltcG9ydCB1cmxlbmNvZGUsIHVucXVvdGUKCWltcG9ydCBzeXMK
CXN5cy5zdGRvdXQud3JpdGUodW5xdW90ZShzeXMuc3RkaW4ucmVhZCgpKSkKCkVudHJ5KCkKCg==" | base64 -d | python - $@
			}
			

			function urlencode(){
				echo "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMgojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLQoKZGVmIEVudHJ5
KCk6CgkKCWZyb20gdXJsbGliIGltcG9ydCB1cmxlbmNvZGUsIHF1b3RlCglpbXBvcnQgc3lzCglz
eXMuc3Rkb3V0LndyaXRlKHF1b3RlKHN5cy5zdGRpbi5yZWFkKCkpKQoKRW50cnkoKQo=" | base64 -d | python - $@
			}
			
