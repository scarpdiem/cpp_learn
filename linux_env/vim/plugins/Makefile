
all: surround.tar.gz pathogen.tar.gz mru.tar.gz vim-markdown.zip
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


vim-markdown.zip: tabular.zip
	wget -O $@ https://github.com/plasticboy/vim-markdown/archive/master.zip

tabular.zip: 
	wget -O $@ https://github.com/godlygeek/tabular/archive/master.zip


# Can't match JavaScript inside html <script> tag
matchit.zip:
	wget -O $@ https://github.com/tmhedberg/matchit/archive/master.zip


# This plugin is now working
# headlights.zip: 
#	wget -O $@ https://github.com/mbadran/headlights/archive/master.zip

