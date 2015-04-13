""
" Optimize the vim's '{' and '}' key for lines consist of blank characters
"

nnoremap { :call BlockMoveUp()<CR>$zz
nnoremap } :call BlockMoveDown()<CR>$zz


function! BlockMoveUp()
	let l:l = line(".")
	let l:skipThis=1
	while (l:l > 1)

		let l:whiteSpaceLine = 0
		let l:lineStr = getbufline("%",l)[0]

		if(lineStr =~ "^[[:blank:]\r]*$")
			let l:whiteSpaceLine = 1
		endif

		if (l:whiteSpaceLine==1)
			if l:skipThis==0
				execute "normal! " . (l:l) . "G<CR>"
				return
			endif
		else
			let l:skipThis = 0
		endif
      
		let l:l = l:l-1
	endwhile
	execute "normal! " . (l:l) . "G<CR>"
endfunction

function! BlockMoveDown()
	let l:l = line(".")
	let l:skipThis=1
	while (1)

		let l:whiteSpaceLine = 0
		let l:lineArr = getbufline("%",l)
		if ( len(l:lineArr)==0)
			execute "normal! " . (l:l-1) . "G<CR>"
			return
		endif

		let l:lineStr = l:lineArr[0]
		if(lineStr =~ "^[[:blank:]\r]*$")
			let l:whiteSpaceLine = 1
		endif

		if (l:whiteSpaceLine==1)
			if l:skipThis==0
				execute "normal! " . l:l . "G<CR>"
				return
			endif
		else
			let l:skipThis = 0
		endif
      
		let l:l = l:l+1
	endwhile
endfunction




