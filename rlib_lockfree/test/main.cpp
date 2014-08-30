#include <thread>
#include <mutex>
#include <string>
#include <iostream>
#include <chrono>
using namespace std;

#include "rlib/lockfree/CycleBufferSwsr.h"
#include "rlib/lockfree/_LightWeightMutex.h"
using namespace rlib::lockfree;

void CycleBufferSwsrPerformanceTest(){
    size_t cnt = 3000000;
    {
        CycleBufferSwsr buffer(2*cnt);
        for(size_t i=0; i<cnt; ++i){ // ensure there's enough data to read
            char value=1;
            while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
        }

        mutex mtx;
        auto before = std::chrono::system_clock::now();
        thread writer([&](){
            char value = 1;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtx.lock();
                while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
                mtx.unlock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        thread reader([&](){
            char value = 0;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtx.lock();
                while(atomic<bool>((buffer.ReaderPop(&value,1)))!=true);
                mtx.unlock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        writer.join();
        reader.join();
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"With competition:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }

    {
        CycleBufferSwsr buffer(2*cnt);
        for(size_t i=0; i<cnt; ++i){ // ensure there's enough data to read
            char value=1;
            while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
        }

        mutex mtxWriter;
        mutex mtxReader;
        auto before = std::chrono::system_clock::now();
        thread writer([&](){
            char value = 1;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtxWriter.lock();
                while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
                mtxWriter.unlock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        thread reader([&](){
            char value = 0;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtxReader.lock();
                while(atomic<bool>((buffer.ReaderPop(&value,1)))!=true);
                mtxReader.unlock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        writer.join();
        reader.join();
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"Without competition:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }

    {
        CycleBufferSwsr buffer(2*cnt);
        for(size_t i=0; i<cnt; ++i){ // ensure there's enough data to read
            char value=1;
            while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
        }

        _LightWeightMutex mtx;
        auto before = std::chrono::system_clock::now();
        thread writer([&](){
            char value = 1;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtx.Lock();
                while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
                mtx.UnLock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        thread reader([&](){
            char value = 0;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtx.Lock();
                while(atomic<bool>((buffer.ReaderPop(&value,1)))!=true);
                mtx.UnLock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        writer.join();
        reader.join();
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"With competition, LightWeightMutex:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }

    {
        CycleBufferSwsr buffer(2*cnt);
        for(size_t i=0; i<cnt; ++i){ // ensure there's enough data to read
            char value=1;
            while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
        }

        _LightWeightMutex mtxWriter;
        _LightWeightMutex mtxReader;
        auto before = std::chrono::system_clock::now();
        thread writer([&](){
            char value = 1;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtxWriter.Lock();
                while(atomic<bool>((buffer.WriterPush(&value,1)))!=true);
                mtxWriter.UnLock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        thread reader([&](){
            char value = 0;
            try{
            for(size_t i=0; i<cnt; ++i){
                mtxReader.Lock();
                while(atomic<bool>((buffer.ReaderPop(&value,1)))!=true);
                mtxReader.UnLock();
            }}catch(...){
                cout<<"exception"<<endl;
            }
        });
        writer.join();
        reader.join();
        auto after =  std::chrono::system_clock::now();

        auto micros = std::chrono::duration_cast<std::chrono::microseconds>(after-before).count();
        std::cout
                <<"Without competition, LightWeightMutex:"<<std::endl
                <<"cnt="<<cnt<<std::endl
                <<"micros="<<micros<<std::endl
                <<std::endl;
    }
}

int main()
{

    CycleBufferSwsrPerformanceTest();
    return 0;
}
