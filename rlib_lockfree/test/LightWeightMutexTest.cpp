#include <atomic>
#include <thread>
#include <chrono>
#include <condition_variable>


class LightWeightMutexAtomicInt{
    friend class CycleBufferSwsr;
    friend class CycleBufferMwsr;

	std::atomic<int> locked;
	std::condition_variable condition;

    LightWeightMutexAtomicInt(const LightWeightMutexAtomicInt&);
public:
	LightWeightMutexAtomicInt() :locked(false){}

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void Lock(){
		int expected = 0;
		while (locked.compare_exchange_weak(expected, 1, memoryOrder) != true){
			std::mutex dummy;
			std::unique_lock<std::mutex> lk(dummy);
			auto now = std::chrono::system_clock::now();
			this->condition.wait_until(lk, now + std::chrono::milliseconds(1000), [&](){return locked == false; });
		}
	}

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void UnLock(){
		locked.store(0, memoryOrder);
	}
};

class LightWeightMutexAtomicBool{
    friend class CycleBufferSwsr;
    friend class CycleBufferMwsr;

	std::atomic<bool> locked;
	std::condition_variable condition;

    LightWeightMutexAtomicBool(const LightWeightMutexAtomicBool&);
public:
	LightWeightMutexAtomicBool() :locked(false){}

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void Lock(){
		bool expected = false;
		while (locked.compare_exchange_weak(expected, true, memoryOrder) != true){
			std::mutex dummy;
			std::unique_lock<std::mutex> lk(dummy);
			auto now = std::chrono::system_clock::now();
			this->condition.wait_until(lk, now + std::chrono::milliseconds(1000), [&](){return locked == false; });
		}
	}

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void UnLock(){
		locked.store(false, memoryOrder);
	}
};


class LightWeightMutexAtomicFlag{

    friend class CycleBufferSwsr;
    friend class CycleBufferMwsr;

	std::atomic_flag locked;

	std::condition_variable condition;

    LightWeightMutexAtomicFlag(const LightWeightMutexAtomicFlag&);

public:
	LightWeightMutexAtomicFlag() { locked.clear(); }

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void Lock(){
		bool shouldBreak = false;
		while (locked.test_and_set(memoryOrder) != false){

			std::mutex dummy;
			std::unique_lock<std::mutex> lk(dummy);

			this->condition.wait_until(lk, std::chrono::system_clock::now() + std::chrono::seconds(5), [&](){
                if(locked.test_and_set()==true){
                    return false;
                }
                shouldBreak = true;
                return true;
            });

            if(shouldBreak)
                break;
		}
	}

    template<std::memory_order memoryOrder = std::memory_order_seq_cst>
	void UnLock(){
		locked.clear(memoryOrder);
	}
};


template<typename M,std::memory_order memoryOrder = std::memory_order_seq_cst>
class LightWeightMutexLockGuard{
    M& mtx;
public:
    LightWeightMutexLockGuard(M& io_mutex):mtx(io_mutex){
         mtx.template Lock<memoryOrder>();
    }
    ~LightWeightMutexLockGuard(){
        mtx.template UnLock<memoryOrder>();
    }
};



#include <mutex>
#include <chrono>
#include <iostream>

#include <windows.h>

template <typename M> static
void TestMutex(uint32_t cnt ){
    M mtx;
    auto before = std::chrono::system_clock::now();
    for(uint32_t i=0; i<cnt; ++i){
        LightWeightMutexLockGuard<M,std::memory_order::memory_order_relaxed> guard(mtx);
    }
    auto after =  std::chrono::system_clock::now();

    auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();

    std::cout
            <<typeid(M).name()<<std::endl
            <<"cnt="<<cnt<<std::endl
            <<"micros="<<micros<<std::endl
            <<std::endl;
}

void BasicTest(uint32_t cnt){
    {
        std::mutex mtx;
        auto before = std::chrono::system_clock::now();
        for(uint32_t i=0; i<cnt; ++i){
            mtx.lock();
            mtx.unlock();
        }
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"std::mutex:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }

    {
        auto before = std::chrono::system_clock::now();
        CRITICAL_SECTION section;
        InitializeCriticalSection(&section);
        for(uint32_t i=0; i<cnt; ++i){
            EnterCriticalSection(&section);
            LeaveCriticalSection(&section);
        }
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"CRITICAL_SECTION:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }
}

void LightWeightMutexTest()
{
    uint32_t cnt = 2000000;

    BasicTest(cnt);

    for(int i=0; i<1; ++i){
        TestMutex<LightWeightMutexAtomicFlag>(cnt);
        TestMutex<LightWeightMutexAtomicBool>(cnt);
        TestMutex<LightWeightMutexAtomicInt>(cnt);
    }

    return  ;
}
