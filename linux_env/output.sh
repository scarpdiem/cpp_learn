#!/bin/bash
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

function udpsend(){
python  -c "`echo 'QlpoOTFBWSZTWe2cd/oAANJfgAAwev//Uj/r3K6/79/0UAQ5slWtM9a0zM5wlCBBGmSntGjU01Mx
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
TuJOSmQ9U0DvQvW6ZUcpPaUmLRiJIXraieqJqFQrQhOIlZVa//i7kinChIds47/Q' | b64decode | bzcat`"  $@
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
function urldecode(){
python  -c "`echo 'QlpoOTFBWSZTWY93CBIAABLfgAAwaHewUQIAAAo/5/+gMAClg0JTNR5I9pJ6BG0j1NNNAajSZNGI
AAANACUpo0aAGjQI0YCMMiMQJqe8mCxWlF/arFN/lp0hxcP2h6qAtxzNBzUVYC8RuDjKI3Zjnox8
7IUOXRa65jXw9tNnWoZFlKSU2DJHLS5YRDAHRbHUEHSeJsYI4Ii9M8I6Cu/AozA8NqRrnHYw+1jj
cS1bEl2S8aLJ0kS4fkpI4ztFGLBS/hOTEwjvBdyRThQkI93CBIA=' | b64decode | bzcat`"  $@
}
function urlencode(){
python  -c "`echo 'QlpoOTFBWSZTWasC4oYAABHfgAAwaHOwUQIAAAo/5/+gMAC6mISaPU00aMmQDQ0NAMZNMgZNDIMj
TAjBKEgMjSGCaA0wjRURSKTtr1dCxpzlDKbFvu5nGek48rE0UiXeGYqsMAuBbgSYWB4fDTU6Xrsg
Z1ayJ4c7FBDImEWtyhFKqkTW0Dp5K1p9rMSStTU8ZRl0Hay7bn5IGxUZluGBwUZ8y81EuloSEEwO
ZKVo+8Uc/E4R+Uw0norIEBL6C7kinChIVYFxQwA=' | b64decode | bzcat`"  $@
}
function getRoxVimrcFile(){

	local roxVimrcFile=/tmp/rox_vimrc_$(echo "$(whoami)" | b64encode )
	
echo 'CnNldCBub2NvbXBhdGlibGUJIiBVc2UgVmltIGRlZmF1bHRzIChtdWNoIGJldHRlciEpCnNldCBi
cz1pbmRlbnQsZW9sLHN0YXJ0CQkiIGFsbG93IGJhY2tzcGFjaW5nIG92ZXIgZXZlcnl0aGluZyBp
biBpbnNlcnQgbW9kZQoic2V0IGFpCQkJIiBhbHdheXMgc2V0IGF1dG9pbmRlbnRpbmcgb24KInNl
dCBiYWNrdXAJCSIga2VlcCBhIGJhY2t1cCBmaWxlCnNldCB2aW1pbmZvPScyMCxcIjUwCSIgcmVh
ZC93cml0ZSBhIC52aW1pbmZvIGZpbGUsIGRvbid0IHN0b3JlIG1vcmUKCQkJIiB0aGFuIDUwIGxp
bmVzIG9mIHJlZ2lzdGVycwpzZXQgaGlzdG9yeT01MAkJIiBrZWVwIDUwIGxpbmVzIG9mIGNvbW1h
bmQgbGluZSBoaXN0b3J5CnNldCBydWxlcgkJIiBzaG93IHRoZSBjdXJzb3IgcG9zaXRpb24gYWxs
IHRoZSB0aW1lCgoKIiBPbmx5IGRvIHRoaXMgcGFydCB3aGVuIGNvbXBpbGVkIHdpdGggc3VwcG9y
dCBmb3IgYXV0b2NvbW1hbmRzCmlmIGhhcygiYXV0b2NtZCIpCiAgYXVncm91cCByZWRoYXQKICBh
dXRvY21kIQogICIgSW4gdGV4dCBmaWxlcywgYWx3YXlzIGxpbWl0IHRoZSB3aWR0aCBvZiB0ZXh0
IHRvIDc4IGNoYXJhY3RlcnMKICBhdXRvY21kIEJ1ZlJlYWQgKi50eHQgc2V0IHR3PTc4CiAgIiBX
aGVuIGVkaXRpbmcgYSBmaWxlLCBhbHdheXMganVtcCB0byB0aGUgbGFzdCBjdXJzb3IgcG9zaXRp
b24KICBhdXRvY21kIEJ1ZlJlYWRQb3N0ICoKICBcIGlmIGxpbmUoIidcIiIpID4gMCAmJiBsaW5l
ICgiJ1wiIikgPD0gbGluZSgiJCIpIHwKICBcICAgZXhlICJub3JtYWwhIGcnXCIiIHwKICBcIGVu
ZGlmCiAgIiBkb24ndCB3cml0ZSBzd2FwZmlsZSBvbiBtb3N0IGNvbW1vbmx5IHVzZWQgZGlyZWN0
b3JpZXMgZm9yIE5GUyBtb3VudHMgb3IgVVNCIHN0aWNrcwogIGF1dG9jbWQgQnVmTmV3RmlsZSxC
dWZSZWFkUHJlIC9tZWRpYS8qLC9tbnQvKiBzZXQgZGlyZWN0b3J5PX4vdG1wLC92YXIvdG1wLC90
bXAKICAiIHN0YXJ0IHdpdGggc3BlYyBmaWxlIHRlbXBsYXRlCiAgYXV0b2NtZCBCdWZOZXdGaWxl
ICouc3BlYyAwciAvdXNyL3NoYXJlL3ZpbS92aW1maWxlcy90ZW1wbGF0ZS5zcGVjCiAgYXVncm91
cCBFTkQKZW5kaWYKCgppZiBoYXMoImNzY29wZSIpICYmIGZpbGVyZWFkYWJsZSgiL3Vzci9iaW4v
Y3Njb3BlIikKICAgc2V0IGNzcHJnPS91c3IvYmluL2NzY29wZQogICBzZXQgY3N0bz0wCiAgIHNl
dCBjc3QKICAgc2V0IG5vY3N2ZXJiCiAgICIgYWRkIGFueSBkYXRhYmFzZSBpbiBjdXJyZW50IGRp
cmVjdG9yeQogICBpZiBmaWxlcmVhZGFibGUoImNzY29wZS5vdXQiKQogICAgICBjcyBhZGQgY3Nj
b3BlLm91dAogICAiIGVsc2UgYWRkIGRhdGFiYXNlIHBvaW50ZWQgdG8gYnkgZW52aXJvbm1lbnQK
ICAgZWxzZWlmICRDU0NPUEVfREIgIT0gIiIKICAgICAgY3MgYWRkICRDU0NPUEVfREIKICAgZW5k
aWYKICAgc2V0IGNzdmVyYgplbmRpZgoKCiIgU3dpdGNoIHN5bnRheCBoaWdobGlnaHRpbmcgb24s
IHdoZW4gdGhlIHRlcm1pbmFsIGhhcyBjb2xvcnMKIiBBbHNvIHN3aXRjaCBvbiBoaWdobGlnaHRp
bmcgdGhlIGxhc3QgdXNlZCBzZWFyY2ggcGF0dGVybi4KaWYgJnRfQ28gPiAyIHx8IGhhcygiZ3Vp
X3J1bm5pbmciKQogIHN5bnRheCBvbgogIHNldCBobHNlYXJjaAplbmRpZgoKCmZpbGV0eXBlIHBs
dWdpbiBvbgoKCmlmICZ0ZXJtPT0ieHRlcm0iCglzZXQgdF9Dbz04CglzZXQgdF9TYj0bWzQlZG0K
CXNldCB0X1NmPRtbMyVkbQplbmRpZgoKIiBEb24ndCB3YWtlIHVwIHN5c3RlbSB3aXRoIGJsaW5r
aW5nIGN1cnNvcjoKIiBodHRwOi8vd3d3LmxpbnV4cG93ZXJ0b3Aub3JnL2tub3duLnBocApsZXQg
Jmd1aWN1cnNvciA9ICZndWljdXJzb3IgLiAiLGE6YmxpbmtvbjAiCgoiIiIiIiIiIiIiIiIiIiIi
IiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiIiCiIgdGhlIG1hcHBpbmcgcmVx
dWlyZXMgdGhlIGFib3ZlIGNvZGUgdG8gZXhlY3V0ZWQgZmlyc3QKCiIgZmlsZSB0YWIgc3dpdGNo
aW5nIApubm9yZW1hcCB0ZSAgOnRhYmVkaXQgCm5ub3JlbWFwIHRzICA6dGFiIHNwbGl0PENSPgpu
bm9yZW1hcCB0biAgOnRhYm48Q1I+Cm5ub3JlbWFwIHRwICA6dGFiTjxDUj4Kbm5vcmVtYXAgPFMt
bD4gOnRhYm48Q1I+Cm5ub3JlbWFwIDxTLWg+IDp0YWJOPENSPgoKIiBmaWxlIHRhYiBoaWdobGln
aHRpbmcKaGkgVGFiTGluZVNlbCAgICAgIHRlcm09Ym9sZCBjdGVybT1ib2xkCmhpIFRhYkxpbmUg
ICAgICAgICB0ZXJtPXVuZGVybGluZSBjdGVybT11bmRlcmxpbmUgY3Rlcm1mZz0wIGN0ZXJtYmc9
NwpoaSBUYWJMaW5lRmlsbCAgICAgdGVybT1yZXZlcnNlIGN0ZXJtPXJldmVyc2UKCiIgZm9sZGlu
ZwpzZXQgZm9sZGVuYWJsZQpzZXQgZm9sZG1ldGhvZD1zeW50YXgKc2V0IGZvbGRsZXZlbD0xMDAK
CiIgaW5kZW50YXRpb24Kc2V0IHRhYnN0b3A9NApzZXQgc29mdHRhYnN0b3A9NApzZXQgc2hpZnR3
aWR0aD00IApzZXQgbm9leHBhbmR0YWIKCgo=' | b64decode > $roxVimrcFile
echo "$roxVimrcFile"
}
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
