
touch foo_hello
touch prefix_foo_postfix

mkdir dir
mkdir dir/subdir
touch dir/subdir/foo_hello

mkdir dir2
touch dir2/file
ln -s `readlink -f .` dir2/link


tree .


set -x

find dir

find . -name "foo*"

find . -type l

find . -type l -exec readlink -f {} \;

# clean
set +x
echo begin cleanning ...

rm foo_hello
rm prefix_foo_postfix

rm -r dir

rm -r dir2

