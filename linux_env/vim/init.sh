{

	unalias vim 2>/dev/null
	roxVimRcFile=$(getRoxVimrcFile)
	alias vim="$(which vim | awk '{print $NF}') --cmd \"source $roxVimRcFile\" -p"
	alias vim 1>&2

	localVimDir=".local_vim"

	cd $(dirname ${BASH_SOURCE[0]}) 
	echo "$(dirname ${BASH_SOURCE[0]})" 1>&2
	if [[ -d $(pwd)/${localVimDir} ]]; then

		# use --cmd option to execute cmd before any vimrc file loaded to make pathogen work
		alias vim="$(pwd)/${localVimDir}/bin/vim -u \"$roxVimRcFile\" -p"
		alias vim 1>&2

		echo "
			set nocompatible
			syntax off
			filetype off
			
			set rtp+=$(pwd)/${localVimDir}/
			set rtp+=$(pwd)/${localVimDir}/vim-pathogen/

			execute pathogen#infect('$(pwd)/${localVimDir}/bundle/{}')

			syntax on
			filetype plugin indent on
		" >> $roxVimRcFile

		if [[ "$(getPluginsTgzEncodedContentMd5sum)" != "$(cat  ${localVimDir}/plugins_md5sum.txt 2>/dev/null )" ]]
		then

			echo "updating vim plugins" 1>&2

			rm -rf ${localVimDir}/plugins_md5sum.txt ${localVimDir}/plugins ${localVimDir}/plugins.tar.gz ${localVimDir}/bundle ${localVimDir}/pathogen
	
			# decompress vim plugins
			echo "$(getPluginsTgzEncodedContent)" | b64decode > ${localVimDir}/plugins.tar.gz
			tar -zxf ${localVimDir}/plugins.tar.gz -C ${localVimDir}/ && rm ${localVimDir}/plugins.tar.gz
			getPluginsTgzEncodedContentMd5sum > ${localVimDir}/plugins_md5sum.txt
			for file in $(find ${localVimDir}/plugins/ -name "*.tar.gz") ; do
				tar -xzf $file -C ${localVimDir}/plugins/
				rm $file
			done
			for file in $(find ${localVimDir}/plugins/ -name "*.zip") ; do
				unzip $file
				rm $file
			done

			# pathogen, the vim plugin manager
			mkdir -p  ${localVimDir}/bundle
			mv ${localVimDir}/plugins/vim-pathogen ${localVimDir}/

			# all other vim plugins
			for file in $(ls ${localVimDir}/plugins/) ; do
				mv ${localVimDir}/plugins/$file ${localVimDir}/bundle/
			done

		fi
		
	fi
	cd - 1>&2 # go back

	# ctags
	unalias ctags 2>/dev/null
	alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"
}
