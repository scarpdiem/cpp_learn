
export: get_source
	mkdir -p tmp/.local_software
	cp Makefile *.*  tmp/.local_software/
	cd tmp && zip -r local_software.zip .local_software
	mv tmp/local_software.zip ./
	rm -rf tmp


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

