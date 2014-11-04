
if compile vim from source, then:

	./configure --prefix=$(readlink -f ~/roxma/.local_vim)/ --with-features=huge  --enable-pythoninterp && make && make install

if compile cmake from source:

	mkdir ~/.local_cmake
	./configure --prefix=$(readlink -f ~/.local_cmake)/
	make && make install


