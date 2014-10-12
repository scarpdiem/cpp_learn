#include "pthread.h"
#include "rlib/thread/Mutex.h"
using rlib::thread::Mutex;
#include "rlib/thread/LockScope.h"
using rlib::thread::LockScope;

#include <iostream>
using std::cout;
using std::endl;

void* thread(void* mutex){
	Mutex & mtx = *(Mutex*)mutex;
	LockScope lock(mtx); (void)lock;
	cout<<"thread now has acquired lock."<<endl;
	return 0;
}

int main(){
	Mutex mutex;
	pthread_t t;

	{
		LockScope lock(mutex);(void)lock;
		pthread_create(&t,NULL,thread,&mutex);
		sleep(3);
	}

	pthread_join(t,NULL);

	return 0;
}
