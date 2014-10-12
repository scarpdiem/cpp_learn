#!/bin/sh

# set -x


name="roxma"


echo "1. Hello\nMy name is $name"

echo '2. Hello\nMy name is $name'

# Words of the form $'string' are treated as ANSI-C Quoting
echo $'3. Hello\nMy name is $name'


# only specific characters will be escape in double quotes
echo "4. Hello My \$name is \"$name\""
# the "'" character, for example, cannot be escapes
echo "5. Hello My name is \'$name\'"

