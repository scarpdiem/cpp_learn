



# Environment setup

Compile vim from source with:

	./configure --prefix=$(readlink -f ~/roxma/.local_vim)/ --with-features=huge  --enable-pythoninterp && make && make install


Compile cmake from source with:

	mkdir ~/.local_cmake
	./configure --prefix=$(readlink -f ~/.local_cmake)/
	make && make install




# A Minimum List of Useful Commands:


### Normal mode Movint

- `Ctrl-O`	Jump back to the previous (older) location. Use the ':jumps' command to see a list of jump history.
- `Ctrl-I`	(same as Tab) Jump forward to the next (newer) location.


### Command Line editing

- `Ctrl-B`	Move to beginning of command line.
- `Ctrl-E`	Move to end of command line.
- `Ctrl-W`	Delete the word before the cursor.  - Ctrl-U	Delete the word before the cursor.
- `Ctrl-F`	Open command line window.


### Search and Replace

#### Replace one by one

`:s/search_string/replace_string/` to replace the first string found in the cursor line, Then `n` to find the next, then `&` to repeat the last substitute command.

`s`	substitute
	
#### Replace all

`:%s/search_string/replace_string/g`

`%`	Traverse and Execute all lines
`g`	Replace all occurance in the line.

#### Replace inside blocks

`v` or `V`, and then `:s/search_string/replace_string/`

