#include "rlib/thread/MutexBase.h"

#include <pthread.h>

namespace rlib{ namespace thread{

class MutexPosix: public MutexBase{
	pthread_mutex_t m_mutex;
public:
	MutexPosix(){
		pthread_mutex_init(&m_mutex,NULL);
	}

	virtual int Lock(){
		pthread_mutex_lock(&m_mutex);
		return 0;
	}

	virtual int UnLock(){
		pthread_mutex_unlock(&m_mutex);
		return 0;
	}

	virtual ~MutexPosix(){
		pthread_mutex_unlock(&m_mutex);
	};
};

}}

