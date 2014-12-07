
export: get_source
	mkdir -p tmp/.local_software
	cp Makefile *.*  tmp/.local_software/
	cd tmp && zip -r local_software.zip .local_software
	mv tmp/local_software.zip ./
	rm -rf tmp

clean:
	rm -rf *.zip
	rm -rf local_*


##
# vim 
#
get_source: vim.zip
vim.zip:
	wget -O $@ https://github.com/b4winckler/vim/archive/master.zip
install: local_vim
local_vim: PREFIX=$(shell readlink -f .)/local_vim/
local_vim:
	unzip vim.zip
	mkdir -p local_vim
	cd vim-master && ./configure --prefix="$(PREFIX)" --with-features=huge  --enable-pythoninterp && make && make install
	rm -rf vim-master
# sudo yum install hg


get_source: subversion-1.8.10.tar.gz sqlite-amalgamation-3071501.zip apr-1.5.1.tar.gz apr-util-1.5.4.tar.gz openssl-1.0.1j.tar.gz
subversion-1.8.10.tar.gz:
	wget -O $@ http://mirror.bit.edu.cn/apache/subversion/subversion-1.8.10.tar.gz
sqlite-amalgamation-3071501.zip:
	wget http://www.sqlite.org/sqlite-amalgamation-3071501.zip
apr-1.5.1.tar.gz:
	wget http://mirror.bit.edu.cn/apache/apr/apr-1.5.1.tar.gz
apr-util-1.5.4.tar.gz: 
	wget http://mirror.bit.edu.cn/apache/apr/apr-util-1.5.4.tar.gz
openssl-1.0.1j.tar.gz:
	wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz
# serf-1.3.8.tar.bz2:
# install: subversion
subversion: PREFIX=$(shell readlink -f .)/subversion/
subversion:
	mkdir subversion
	tar -zxf apr-1.5.1.tar.gz
	cd apr-1.5.1 && ./configure --prefix=$(PREFIX) && make && make install
	tar -zxf apr-util-1.5.4.tar.gz
	cd apr-util-1.5.4 && ./configure --prefix=$(PREFIX)  --with-apr=$(PREFIX) && make && make install
	tar -zxf openssl-1.0.1j.tar.gz
	cd openssl-1.0.1j && ./config --shared --prefix=$(PREFIX)  && make && make install
	tar -xjf serf-1.2.1.tar.bz2
	cd serf-1.2.1 && ./configure --with-openssl=$(PREFIX) --with-apr=$(PREFIX) --with-apr-util=$(PREFIX) --prefix=$(PREFIX) && make && make install
	tar -zxf subversion-1.8.10.tar.gz
	unzip sqlite-amalgamation-3071501.zip && mv sqlite-amalgamation-3071501 subversion-1.8.10/sqlite-amalgamation
	cd subversion-1.8.10 && ./configure --with-apr=$(PREFIX) --with-apr-util=$(PREFIX) --with-serf=$(PREFIX) --prefix=$(PREFIX) && make && make install
	rm -rf apr-1.5.1 apr-util-1.5.4  subversion-1.8.10 serf-1.2.1 openssl-1.0.1j

# subversion:

# lib
