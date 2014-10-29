#!/bin/bash

echo "function getRoxVimrcFile(){"
	vimrcEncodedContent="$(cat *vimrc | base64)"

	echo '
	local roxVimrcFile=/tmp/rox_vimrc_$(echo "$(whoami)" | b64encode )
	'
	echo "echo '$vimrcEncodedContent' | b64decode > \$roxVimrcFile"
	echo "echo \"\$roxVimrcFile\""

echo "}"


cat init.sh

