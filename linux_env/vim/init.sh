{

	unalias vim 2>/dev/null
	customVimrcFile=$(getRoxVimrcFile)
	alias vim="$(which vim | awk '{print $NF}') --cmd \"source $customVimrcFile\" -p"
	alias vim 1>&2

	localVimDir=".local_software/local_vim"

	cd $(dirname ${BASH_SOURCE[0]})

	echo "$(dirname ${BASH_SOURCE[0]})" 1>&2
	if [[ -d $(pwd)/${localVimDir} ]]; then

		# use --cmd option to execute cmd before any vimrc file loaded to make pathogen work
		unalias vim 2>/dev/null
		alias vim="$(pwd)/${localVimDir}/bin/vim -u \"$customVimrcFile\" -p"
		alias vim 1>&2

		# prepend some script to the vimrc file.
		echo "
			let s:customvimrc_local_software_dir='$(pwd)/.local_software/'

			\" add pathogen initialization to the beginning of vimrc file
			set rtp+=$(pwd)/${localVimDir}/
			set rtp+=$(pwd)/${localVimDir}/vim-pathogen-master/

			set nocompatible
			execute pathogen#infect('$(pwd)/${localVimDir}/bundle/{}')
			syntax on
			filetype plugin indent on
		" > ${customVimrcFile}.tmp
		cat ${customVimrcFile} >> ${customVimrcFile}.tmp
		mv ${customVimrcFile}.tmp ${customVimrcFile}

		# If plugins has changed
		if [[ "$(getPluginsTgzEncodedContentMd5sum)" != "$(cat ${localVimDir}/plugins_md5sum.txt 2>/dev/null )" ]]
		then

			echo "updating vim plugins" 1>&2

			# first clean the old plugins
			rm -rf ${localVimDir}/plugins_md5sum.txt ${localVimDir}/plugins ${localVimDir}/plugins.tar.gz ${localVimDir}/bundle ${localVimDir}/vim-pathogen-master

			# decompress new vim plugins
			echo "$(getPluginsTgzEncodedContent)" | base64_decode > ${localVimDir}/plugins.tar.gz			# plugins.tar.gz
			tar -zxf ${localVimDir}/plugins.tar.gz -C ${localVimDir}/ && rm ${localVimDir}/plugins.tar.gz	# decompress plugins.tar.gz
			getPluginsTgzEncodedContentMd5sum > ${localVimDir}/plugins_md5sum.txt
			for file in $(find ${localVimDir}/plugins/ -name "*.tar.gz") ; do		# vimplugin.tar.gz
				tar -xzf $file -C ${localVimDir}/plugins/
				rm $file
			done
			for file in $(find ${localVimDir}/plugins/ -name "*.zip") ; do			# vimplugin.zip
				unzip -q -d ${localVimDir}/plugins/ $file
				rm $file
			done

			# pathogen, the vim plugin manager
			mkdir -p  ${localVimDir}/bundle
			mv ${localVimDir}/plugins/vim-pathogen-master ${localVimDir}/

			# all other vim plugins
			for pluginDir in $(ls ${localVimDir}/plugins/) ; do
				mv ${localVimDir}/plugins/$pluginDir ${localVimDir}/bundle/
				# add the plugin documentation to vim
				if [[ -d  ${localVimDir}/bundle/$pluginDir/doc ]] ; then
					echo  "set runtimepath+=${localVimDir}/bundle/$pluginDir/doc" >> $customVimrcFile
					${localVimDir}/bin/vim -E -c "helptags ${localVimDir}/bundle/$pluginDir/doc" -c q
				fi
			done

		fi

	fi
	cd - 1>&2 # go back

	# ctags
	unalias ctags 2>/dev/null
	alias ctags="$(which ctags | awk '{print $NF}') --c-kinds=+p --c++-kinds=+p"
}
