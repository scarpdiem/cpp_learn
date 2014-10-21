
function b64decode(){
	python -c '
import base64, sys
sys.stdout.write(base64.b64decode(sys.stdin.read()))
	'
}
