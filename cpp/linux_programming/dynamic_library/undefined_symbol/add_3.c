#include <stdio.h>

int some_function_not_defined();

int add(int a, int b) {
	some_function_not_defined(); // call an external function
	return a+b;
}
