
if compile vim from source, then:

	./configure --prefix=$(readlink -f ~/roxma/.local_vim)/ --with-features=huge  --enable-pythoninterp && make && make install


if compile cmake from source:

	mkdir ~/.local_cmake
	./configure --prefix=$(readlink -f ~/.local_cmake)/
	make && make install


List of useful commands:

- Ctrl-O	Jump back to the previous (older) location. Use the ':jumps' command to see a list of jump history.
- Ctrl-I	(same as Tab) Jump forward to the next (newer) location.

