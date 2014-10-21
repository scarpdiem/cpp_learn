#!/bin/bash
#!/bin/bash


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


function b64encode(){
	python -c '
import base64, sys
sys.stdout.write(base64.b64encode(sys.stdin.read()))
	'
}

function b64decode(){
	python -c '
import base64, sys
sys.stdout.write(base64.b64decode(sys.stdin.read()))
	'
}

			function udpsend(){
				  python  -c "$(echo 'QlpoOTFBWSZTWe2cd/oAANJfgAAwev//Uj/r3K6/79/0UAQ5slWtM9a0zM5wlCBBGmSntGjU01Mx
Jo0aGQZA9Teoj1NBppGmQmpqmmTyTNQaNAZGEMTTQ09TQAlPUKJqYofqNBME0aAaAAAAADmBMTQY
TJkyZGEwTTTIxMAQwCU1Eap4RlHpPUbU8obUNAAABoADRIEVIQYFgFBRhYFUEWFBERYFUUQfVp4f
PMkMiaq+9MwTMk4IdNxa1hthZlkROasamJgEipTbIYSO9uuNJFrUzPDuoxySBmOVEuusZxNy6OFJ
35mJHg4sWlRRUZa3tguCGDURmJzhoSip5TYyLhQ1VeN75RMjzGsxfkd48bG8RfKMQuiBM38ne2NX
ax54puYlndUGdrti01idxirbxzzo/6VSWro1adDu6PmsxRyJNilJme2wswJqrjzfHXLQ+VY/e3Ty
cxzjDKnOLiZG0ig10Gr8WvmJiZAuNeuj8LjhwpBHhAuTdSfLvnSmsyyeHaRVVXK2otuf7Xjz69LW
bKBeD5RacqebegrqwlXlqqW1pR4QgvuKDjTMRRXPHf0RqU0cVRVXZZcBjBKX4trYf2bV2YS+Mtzr
/hDsbY6XJahXZl5tMMrZI6pRW73xudDdquLhFCURCCiXvy9v20d3bgLVuJbEdJHXdfnCjrp9xqE9
ke1JcJYkhvT9RDMvXbm1H07rvD9zhvXIKvQocxnDug3HpPL/JxxD9p2Tp9pMXl43rhv0iYOKYoeS
linfjRybXKoYzC3dB4HmLz4U6Y06Wqi7LaOSidEbQ1z4mu528O/yQGKH1IwjCeceWTfTHq+T6XUr
F0wIm1MYuJIsYiWQQ7PnHY0VhgNCQlAU4zrr2tlZtWBQd0YFNnQO6hOzXYdGzTuLDqnkmyDwcUzz
Xjo5sSsvpg6OjWP1a3Gx8ypUZwqSqkIKn5U5KjqrjnOw1xSQoxJOVx3Iwg0dY57SjsXnFMZRBNqu
w7agtGBXhsQyoK1ZjZRE4pbQe9lIPiJlKbD2ePKJygy3MDJL/wSVFRKwkmKwwSHNOiMCC6DpSY1N
STZCV4y8YNMGbOfBB1M7c9aYVrI2MGUBwlEyoaW6GYzLRpE85xB5kPPGJYnVh3vK+01hQbWWlmVN
rzOaNxpcBaQcmdTi5MyiwYov10ojHazhroQpial0doFKnMmjNpCBKlZWhhLwjGygUg7ZMFTBtWQZ
hbpKVNdUsTn/xHuMTiigpiQGdeQy5SjIePImDb3zeY4NLMPBMFAZJlEVgQqJhylEjoIZnRvadrVW
ZbNlU0jWqdd3RZhJbtrDxIoZxOVCFd2kVWbTmXpRUdEkgRYKJATaBEUyQVIZqsSURmQbpVA9nGTg
TuJOSmQ9U0DvQvW6ZUcpPaUmLRiJIXraieqJqFQrQhOIlZVa//i7kinChIds47/Q' | b64decode  | bzcat)"  $@
			}
			

			function urldecode(){
				  python  -c "$(echo 'QlpoOTFBWSZTWY93CBIAABLfgAAwaHewUQIAAAo/5/+gMAClg0JTNR5I9pJ6BG0j1NNNAajSZNGI
AAANACUpo0aAGjQI0YCMMiMQJqe8mCxWlF/arFN/lp0hxcP2h6qAtxzNBzUVYC8RuDjKI3Zjnox8
7IUOXRa65jXw9tNnWoZFlKSU2DJHLS5YRDAHRbHUEHSeJsYI4Ii9M8I6Cu/AozA8NqRrnHYw+1jj
cS1bEl2S8aLJ0kS4fkpI4ztFGLBS/hOTEwjvBdyRThQkI93CBIA=' | b64decode  | bzcat)"  $@
			}
			

			function urlencode(){
				  python  -c "$(echo 'QlpoOTFBWSZTWT3+gYYAABJfgAAwaHewUQIAAAo/5/+gMAClg0JTZR5I/RR6JkbSPU000BqnkmjR
iAAADQAlKI9TanlPUzSPKGEepkxPQyIwpOT3iy2KOEodm4JtL4KrveP2ZqNDCi6iIOMRZ1F4lcHm
UhszDLNkKWrU58otbQaeIOrq/mhkWM5pXULkapLVBEL4bFsUAQSSiZGDIGZ8g3BPXY9eWHBgkdox
JiyTyBmJ3UtGtSI8UORkCg4M8E0YeuRTx9jho0SG4u5IpwoSB7/QMMA=' | b64decode  | bzcat)"  $@
			}
			
