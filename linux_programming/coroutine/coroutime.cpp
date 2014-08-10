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
	bool stopped;

	void *stackbase;
	size_t stacksize;
	pthread_attr_t attr;
	
	RoutineInfo(size_t size){

		param = NULL;
		handler = NULL;
		ret = NULL;
		stopped = false;

		stackbase = malloc(size);
		stacksize = 0;
		if(stackbase!=NULL)
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
	routines.pop_front();
	if(current->stopped){
		longjmp( (*routines.begin())->buf ,1);
	}
	routines.push_back(current);		// adjust the routines to the end of list
	if(routines.size()==1) return 0;	// no other thread
	if( !setjmp(current->buf) ){
		longjmp( (*routines.begin())->buf ,1);
	}
}

void *coroutine(void *pRoutineInfo){

	RoutineInfo& info = *(RoutineInfo*)pRoutineInfo;

	if( !setjmp(info.buf)){
		
		// back up the stack, and then exit
		stackBackup = realloc(stackBackup,info.stacksize);
		memcpy(stackBackup,info.stackbase, info.stacksize);

		pthread_exit(NULL);

		return (void*)0;
	}

	info.ret = info.handler(info.param);
	
	// never return
	info.stopped = true;
	Switch();
	
	return (void*)0; // suppress compiler warning
}

int CreateCoRoutine(RoutineHandler handler,void* param ){
	RoutineInfo* info = new RoutineInfo(PTHREAD_STACK_MIN+ 0x4000);
	if(info->stackbase==NULL){
		delete info;
		return __LINE__;
	}

	info->param = param;
	info->handler = handler;

	pthread_t thread;
	int ret = pthread_create( &thread, &(info->attr), coroutine, info);
	if(ret){
		delete info;
		return __LINE__;
	}

	void* status;
	pthread_join(thread,&status);

	if(stackBackup == NULL){
		delete info;
		return __LINE__;
	}
	
	// restore
	memcpy(info->stackbase,stackBackup,info->stacksize);

	// add the routine to the end of the list
	routines.push_back(info);
	
	return 0;
}

#include <sys/wait.h>

void* foo(void*){
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
		Switch();
	}
}

