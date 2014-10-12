#include <exception>

#include <iostream>

#include "rlib/log/LogCapture.h"

using namespace std;

void fun(void* t= 0);

struct Foo{
	~Foo(){
		if(uncaught_exception()){
			cout<<"exception"<<endl;
			cout<<this<<endl;
			//fun();
		}
	}
};

void fun(void* t){
	cout<<t<<endl;
}

int main(){
	int i;

	try{
		Foo f;
		throw 0;
	}catch(...){
		cout<<"catch"<<endl;
	}
}
