#ifndef RLIB_THREAD_LOCKSCOPE_H
#define RLIB_THREAD_LOCKSCOPE_H

#include "rlib/thread/MutexBase.h"

namespace rlib{ namespace thread{

class LockScope{
	MutexBase& m_oMutex;
public:
	LockScope(MutexBase& mutex):m_oMutex(mutex){ m_oMutex.Lock(); }
	~LockScope(){ m_oMutex.UnLock(); }
};

}}

#endif

