#include <limits.h>
#include <string.h>
#include <list>
#include <pthread.h>
#include <setjmp.h>
#include <malloc.h>


#include <iostream>
using namespace std;

typedef void * (*RoutineHandler)(void*);

void *stackBackup = NULL;

struct RoutineInfo{
	jmp_buf buf;
	void * param;
	RoutineHandler handler;
	void * ret;
	pthread_mutex_t mutex;
	pthread_t thread;
	bool stopped;
	bool started;

	void *stackbase;
	size_t stacksize;

	pthread_attr_t attr;
	
	RoutineInfo(size_t size){
		param = NULL;
		handler = NULL;
		ret = NULL;
		stopped = false;
		started = false;

		pthread_mutex_t init = PTHREAD_MUTEX_INITIALIZER;
		memcpy(&(mutex),&init,sizeof(init));
		
		thread = pthread_t();

		stackbase = malloc(size);
		stacksize = size;

		pthread_attr_init(&attr);
		if(stacksize)
			pthread_attr_setstack(&attr,stackbase,stacksize);
	}
	
	~RoutineInfo(){
		if(stacksize)
			pthread_attr_destroy(&attr);

		free(stackbase);
	}
};

std::list<RoutineInfo*> InitRoutines(){
	std::list<RoutineInfo*> list;

	RoutineInfo *main = new RoutineInfo(0);

	list.push_back(main);

	return list;
}
std::list<RoutineInfo*> routines = InitRoutines();

int Switch(){
	RoutineInfo* current = routines.front();
	if(current->stopped){
		cout<<"stop true, jmp directly"<<endl;
		longjmp( (*++routines.begin())->buf ,1);
	}
	if(routines.size()==1) return 0;
	cout<<"setjmp"<<endl;
	if( !setjmp(current->buf) ){
		longjmp( (*++routines.begin())->buf ,1);
	}else{
		cout<<"restore"<<endl;
		RoutineInfo* last = routines.front();
		routines.pop_front();
		if(last->stopped){

		}else{
			routines.push_back(last);
			cout<<"scroll"<<endl;
		}
		cout<<"getfront"<<endl;
		RoutineInfo* thisRoutine = routines.front();
	}
}

void *coroutine(void *pRoutineInfo){

	RoutineInfo& info = *(RoutineInfo*)pRoutineInfo;
	if( !setjmp(info.buf)){
		
		cout<<"thread exit!"<<&pRoutineInfo<<endl;

		stackBackup = realloc(stackBackup,info.stacksize);
		memcpy(stackBackup,info.stackbase, info.stacksize);

		pthread_exit(NULL);

		return (void*)0;
	}


	// adjust the list
	RoutineInfo* last = routines.front();
	routines.pop_front();
	if(last->stopped){
		// unlock mutex, but do not delete last here
		pthread_mutex_unlock( &(last->mutex));
	}else{
		routines.push_back(last);
	}
	RoutineInfo* thisRoutine = routines.front();

	info.ret = info.handler(info.param);
	
	// never return
	info.stopped = true;
	cout<<"stop true"<<endl;
	Switch();
	
	return (void*)0; // suppress compiler warning
}

int CreateCoRoutine(RoutineHandler handler,void* param ){
	RoutineInfo* info = new RoutineInfo(PTHREAD_STACK_MIN+ 0x4000);

	info->param = param;
	info->handler = handler;

	pthread_mutex_lock( &(info->mutex));

	RoutineInfo* currentRoutine = *routines.begin();

	int ret = pthread_create( &(info->thread), &(info->attr), coroutine, info);
	
	// if thread create failed, unlock mutex, delete the element from the list

	routines.push_back(info);

	void* status;
	pthread_join(info->thread,&status);

	// restore
	memcpy(info->stackbase,stackBackup,info->stacksize);

	cout<<"gooo!!!"<<endl;
}

#include <sys/wait.h>

void* foo(void*){
	cout<<"in Foo"<<endl;
	for(int i=0; i<5; ++i){
		cout<<"foo: "<<i<<endl;
		sleep(1);
		Switch();
	}
}

int main(){
	CreateCoRoutine(foo,NULL);
	for(int i=0; i<10; ++i){
		cout<<"main: "<<i<<endl;
		sleep(1);
		cout<<"main begin to switch."<<endl;
		Switch();
	}
}

