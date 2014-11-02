{

	# vim 
	unalias vim 2>/dev/null
	roxVimRcFile=$(getRoxVimrcFile)
	alias vim="$(which vim | awk '{print $NF}') --cmd \"source $roxVimRcFile\" -p"
	alias vim 1>&2

	cd $(dirname ${BASH_SOURCE[0]}) 
	echo "$(dirname ${BASH_SOURCE[0]})" 1>&2
	if [[ -d $(pwd)/.local_vim ]]; then

		# use --cmd option to execute cmd before any vimrc file loaded to make pathogen work
		alias vim="$(pwd)/.local_vim/bin/vim --cmd \"source $roxVimRcFile\" -p"
		alias vim 1>&2

		echo "
			set nocompatible
			syntax off
			filetype off
			
			set rtp+=$(pwd)/.local_vim/
			set rtp+=$(pwd)/.local_vim/pathogen/

			execute pathogen#infect('$(pwd)/.local_vim/bundle/{}')

			syntax on
			filetype plugin indent on
		" >> $roxVimRcFile

		# set nocompatible
		# filetype off
		# set rtp+=$(pwd)/.local_vim/bundle/vundle/
		# call vundle#begin()

		# Plugin 'gmarik/Vundle.vim'
		# Plugin 'file://$(pwd)/.local_vim/plugins/nerdtree/autoload/nerdtree.vim'

		# call vundle#end()
		# filetype plugin indent on

		if [[ "$(getPluginsTgzEncodedContentMd5sum)" != "$(cat  .local_vim/plugins_md5sum.txt 2>/dev/null )" ]]
		then

			echo "updating vim plugins" 1>&2

			rm -rf .local_vim/plugins_md5sum.txt .local_vim/plugins .local_vim/plugins.tar.gz .local_vim/bundle .local_vim/pathogen
	
			echo "$(getPluginsTgzEncodedContent)" | b64decode > .local_vim/plugins.tar.gz
			tar -zxf .local_vim/plugins.tar.gz -C .local_vim/ && rm .local_vim/plugins.tar.gz
			getPluginsTgzEncodedContentMd5sum > .local_vim/plugins_md5sum.txt

			for file in .local_vim/plugins/*.tar.gz ; do
				tar -xzf $file -C .local_vim/plugins/
				rm $file
			done
			mkdir -p  .local_vim/bundle
			mv .local_vim/plugins/pathogen .local_vim/
			for file in $(ls .local_vim/plugins/) ; do
				mv .local_vim/plugins/$file .local_vim/bundle/
			done

		fi
		
	fi
	cd - 1>&2 # go back

	# ctags
	unalias ctags 2>/dev/null
	alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"

}
