
if compile vim from source, then:

	./configure --prefix=$(readlink -f ~/roxma/.local_vim)/ --with-features=huge  --enable-pythoninterp && make && make install

