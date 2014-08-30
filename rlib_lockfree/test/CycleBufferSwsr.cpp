#include <thread>
#include <mutex>
#include <string>
#include <iostream>
#include <chrono>
using namespace std;

#include "rlib/lockfree/CycleBufferSwsr.h"
#include "rlib/lockfree/_LightWeightMutex.h"
using namespace rlib::lockfree;

template<typename Mutex>
void test(size_t cnt, Mutex& writerMutex, Mutex& readerMutex){

    CycleBufferSwsr buffer(2*cnt);

    for(size_t i=0; i<cnt; ++i){ // ensure there's enough data to read
        char value=1;
        while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
    }

    auto before = std::chrono::system_clock::now();

    thread writer([&](){
        char value = 1;
        try{
        for(size_t i=0; i<cnt; ++i){
            writerMutex.lock();
            while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
            writerMutex.unlock();
        }}catch(...){
            cout<<"exception"<<endl;
        }
    });

    thread reader([&](){
        char value = 0;
        try{
        for(size_t i=0; i<cnt; ++i){
            readerMutex.lock();
            while(atomic<bool>((buffer.ReaderPop(&value,1)))!=true);
            readerMutex.unlock();
        }}catch(...){
            cout<<"exception"<<endl;
        }
    });

    writer.join();
    reader.join();

    auto after =  std::chrono::system_clock::now();

    auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
    std::cout<<"Mutex name:"<< typeid(Mutex).name()<<std::endl
            << (((&writerMutex)==(&readerMutex)) ? "Lock." : "Lock-free") <<std::endl
            <<"cnt: "<<cnt<<std::endl
            <<"time: "<<micros / 1000000.0 <<" seconds" << std::endl
            <<std::endl;
}

void CycleBufferSwsrPerformanceTest(){

    size_t cnt = 2000000;

    std::mutex mutex1;
    std::mutex mutex2;

    test(cnt,mutex1,mutex1); // lock
    test(cnt,mutex1,mutex2); // lockfree

    _LightWeightMutex lightMutex1;
    _LightWeightMutex lightMutex2;

    test(cnt,lightMutex1,lightMutex1); // lock
    test(cnt,lightMutex1,lightMutex2); // lockfree

    return;
}

int main(){

    CycleBufferSwsrPerformanceTest();
    return 0;
}
