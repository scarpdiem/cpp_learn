#!/bin/bash

echo "function getRoxVimrcFile(){"
vimrcEncodedContent="$(cat $(find ./ -maxdepth 1 -name vimrc -o -name "*.vimrc" -o -name "*.vim")  $(find ./ -mindepth 2 -name vimrc -o -name "*.vimrc" -o -name "*.vim") | base64)"
	echo 'local roxVimrcFile=/tmp/rox_vimrc_$(echo "$(pwd)$(whoami)" | base64_encode )'
	echo "echo '$vimrcEncodedContent' | base64_decode > \$roxVimrcFile"
	echo "echo \"\$roxVimrcFile\""
echo "}"

echo "function getPluginsTgzEncodedContent(){"
	pluginsTgzEncodedContent="$(tar -cz plugins | base64)"
	echo "echo '$pluginsTgzEncodedContent'"
echo "}"

echo "function getPluginsTgzEncodedContentMd5sum(){"
	echo "echo '$(echo $pluginsTgzEncodedContent | md5sum)'"
echo "}"


cat init.sh

