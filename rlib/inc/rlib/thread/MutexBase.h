#ifndef RLIB_THREAD_MUTEXBASE_H
#define RLIB_THREAD_MUTEXBASE_H

namespace rlib{ namespace thread{

class MutexBase{

public:
	MutexBase(){}
	virtual int Lock() = 0;
	virtual int UnLock() = 0;
	virtual ~MutexBase(){};

private:
	MutexBase(const MutexBase&){}
};

}}

#endif
