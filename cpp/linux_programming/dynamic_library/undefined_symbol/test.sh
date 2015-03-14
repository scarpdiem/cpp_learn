
for i in 1 2 3 ; do 

	echo "##############################################"
	echo "### add_${i}"

	gcc -c -fPIC add_${i}.c -o add_${i}.o
	gcc -shared -o libadd_${i}.so add_${i}.o
	ar  rcs libadd_${i}.a      add_${i}.o

	echo "# nm libadd_${i}.a"
	nm libadd_${i}.a

	echo
	echo "# nm -g libadd_${i}.so"
	nm -g libadd_${i}.so

done


echo "##############################################"
echo "### Undefined symbol test"

echo gcc -Wl,--no-undefined -shared -o libadd_2.so add_2.o
gcc -Wl,--no-undefined -shared -o libadd_2.so add_2.o

echo gcc -Wl,--no-undefined -shared -o libadd_3.so add_3.o
gcc -Wl,--no-undefined -shared -o libadd_3.so add_3.o

