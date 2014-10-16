#!/bin/bash


function Entry(){

	local output=output.sh
	echo '#!/bin/bash' > $output

	# handle bashScripts
	local bashScripts=$(find . -mindepth 2 -name "*.sh")
	cat $bashScripts >> $output

	local pythonScripts=$(find . -mindepth 2 -name "*.py")
	for pythonScript in $pythonScripts
	do
		local encodedScriptContent=$(gzip -c $pythonScript | base64)
		local scriptName=$(basename $pythonScript)
		echo "
			function ${scriptName/%.py/}(){
				echo \"$encodedScriptContent\" | base64 -d | zcat | python - \$@
			}
			" >> $output
	done
	
}

Entry

