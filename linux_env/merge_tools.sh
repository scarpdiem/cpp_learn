#!/bin/bash

option_compress=1

function Entry(){

	local output=output.sh
	echo '#!/bin/bash' > $output

	# handle bashScripts
	local bashScripts=$(find . -mindepth 2 -name "*.sh")
	cat $bashScripts >> $output

	local pythonScripts=$(find . -mindepth 2 -name "*.py")
	for pythonScript in $pythonScripts
	do
		local scriptName=$(basename $pythonScript)
		echo \
			"function ${scriptName/%.py/}(){
				  python  -c \"\`$(TextFileEncodedToScript $pythonScript)\`\"  \$@
			}">> $output
	done
	
}

# encode text file content to bash script string
function TextFileEncodedToScript(){
	# The client macine may not have base64 program, thus we use the b64decode 
	# function in the output script file
	local fileName=$1
	if [[ "$option_compress" = "1" ]]; then
		local encodedTextContent=$(bzip2 -c $fileName | base64)
		echo "echo '$encodedTextContent' | b64decode | bzcat"
	else
		local encodedTextContent=$(cat $fileName | base64)
		echo "echo '$encodedTextContent' | b64decode"
	fi
}

Entry

