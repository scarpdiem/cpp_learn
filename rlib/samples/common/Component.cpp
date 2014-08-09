#include "rlib/common/Component.h"

using namespace rlib::common;

#include <iostream>
using std::endl;
using std::cout;

struct Dao : Component<Dao>{
	int i;
	void foo(){
		cout<<"i=5"<<endl;
	}
	Dao():i(5){}
};


// typo
struct Dao2: Component<Dao>{
	int i;
};


int main()
{
	
	ComponentPtr<Dao> dao;
	//ComponentPtr<Dao2> dao2; // compiles error

	dao->foo();
	//Dao2 dao;
    return 0;
}
