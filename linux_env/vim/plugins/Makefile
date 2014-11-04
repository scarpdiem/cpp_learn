
all: surround.tar.gz pathogen.tar.gz mru.tar.gz
	make clean_tmp


surround.tar.gz:
	git clone https://github.com/tpope/vim-surround.git
	tar -zcf surround.tar.gz vim-surround
clean_tmp: clean_tmp_surround.tar.gz
clean_tmp_surround.tar.gz:
	rm -rf vim-surround


pathogen.tar.gz:
	git  clone https://github.com/tpope/vim-pathogen.git
	tar -zcf pathogen.tar.gz vim-pathogen
clean_tmp: clean_tmp_pathogen.tar.gz
clean_tmp_pathogen.tar.gz:
	rm -rf vim-pathogen


mru.tar.gz:
	git clone https://github.com/yegappan/mru.git
	tar -zcf mru.tar.gz mru
clean_tmp: clean_tmp_mru.tar.gz
clean_tmp_mru.tar.gz:
	rm -rf mru

