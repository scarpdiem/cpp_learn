
get_source: vim.zip

install: local_vim

clean:
	rm -rf *.zip
	rm -rf local_*

# sudo yum install hg
vim.zip:
	wget -O $@ https://github.com/b4winckler/vim/archive/master.zip

local_vim:
	unzip vim.zip
	mkdir -p local_vim
	cd vim-master && ./configure --prefix="$$(readlink -f ../local_vim)/" --with-features=huge  --enable-pythoninterp && make && make install
	rm -rf vim-master

