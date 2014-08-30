#ifndef RLF_CYCLEBUFFERSWSR_H
#define RLF_CYCLEBUFFERSWSR_H

#include <atomic>
#include <stddef.h>
#include <memory>
#include <type_traits>
#include <algorithm>
#include  <stdexcept>

#include "rlib/lockfree/_LightWeightMutex.h"

namespace rlib{ namespace lockfree{

/**
 * Single Writer single Reader cycle buffer.
 * This is a data structor that ensures any writer not block any reader, and any reader will
 * not block any writer. However if you have multi writers, writers may block each other.
 * If you have multi readers, they may block each other too.
 */
class CycleBufferSwsr{
private:

	typedef char ElemT;

	static_assert(std::is_object<ElemT>::value, "ElemT must be an object type");

	size_t readPos;
	size_t writePos;
	size_t capacity;
	std::atomic<size_t> readableCount;

	std::unique_ptr<ElemT[]> buffer;

	rlib::lockfree::_LightWeightMutex writerMutex;
	rlib::lockfree::_LightWeightMutex readerMutex;

	CycleBufferSwsr(CycleBufferSwsr&&);
	CycleBufferSwsr(const CycleBufferSwsr&);


	void privateReaderContinuousPop(ElemT* o_pos, size_t i_popCount){
		ElemT* readBase = &(this->buffer[this->readPos]);
		for (size_t i = 0; i < i_popCount; ++i){
			o_pos[i] = readBase[i];
		}
		privateReaderContinuousPop(i_popCount);
	}

	/**
     * Adjust read offset
	 */
	void privateReaderContinuousPop(size_t i_popCount){
		this->readPos += i_popCount;
		this->readPos = this->readPos % this->capacity;
		this->readableCount.fetch_sub(i_popCount, std::memory_order_relaxed);
	}


	void privateWriterContinuousPush(ElemT const* i_pos, size_t i_pushCount){
		ElemT* writeBase = &(this->buffer[this->writePos]);
		for (size_t i = 0; i < i_pushCount; ++i){
			writeBase[i] = i_pos[i];
		}
		privateWriterContinuousPush(i_pushCount);
	}

	/**
	 * Adjust write offset
	 */
	void privateWriterContinuousPush(size_t i_pushCount){
		this->writePos += i_pushCount;
		this->writePos = this->writePos % this->capacity;
		this->readableCount.fetch_add(i_pushCount, std::memory_order_relaxed);
	}


	void privateReaderGetReadableCount(size_t* o_total, size_t* o_continuousCount = nullptr){
		size_t currentReadPos = this->readPos;
		*o_total = this->readableCount.load(std::memory_order_relaxed);

		if (o_continuousCount){
			if (currentReadPos + *o_total > this->capacity){
				*o_continuousCount = this->capacity - currentReadPos;
			}
			else{
				*o_continuousCount = *o_total;
			}
		}
	}

    void privateWriterGetWritableCount(size_t* o_total, size_t* o_continuousCount = nullptr){
		size_t currentWritePos = this->writePos;
		*o_total = this->capacity - this->readableCount.load(std::memory_order_relaxed);

		if (o_continuousCount){
			if (currentWritePos + *o_total > this->capacity){
				*o_continuousCount = this->capacity - currentWritePos;
			}
			else{
				*o_continuousCount = *o_total;
			}
		}
	}

public:
	class Tester;
	friend class Tester;
public:

	CycleBufferSwsr(){
		ReInit(0);
	};

	CycleBufferSwsr(size_t i_capacity){
		ReInit(i_capacity);
	}

	/**
	 * Please ensure there's no other operations during ReInit.
	 */
	void ReInit(size_t i_capacity){
	    _LightWeightMutexLockGuard<std::memory_order_seq_cst> readerGuard(readerMutex);
	    _LightWeightMutexLockGuard<std::memory_order_seq_cst> writerGuard(writerMutex);

		this->readPos = 0;
		this->writePos = 0;
		this->capacity = i_capacity;
		this->readableCount = 0;
		this->buffer = std::unique_ptr<ElemT[]>(i_capacity ? new ElemT[i_capacity] : nullptr);
	}

	void ReaderGetReadableCount(size_t* o_total){
        _LightWeightMutexLockGuard<std::memory_order_seq_cst> guard(readerMutex);
        privateReaderGetReadableCount(o_total,nullptr);
	}

	/**
	 * For reading thread only
	 */
	bool ReaderPop(ElemT* const o_buffer, size_t const i_bufferSize){
        _LightWeightMutexLockGuard<std::memory_order_seq_cst> guard(readerMutex);

		if (this->readableCount.load(std::memory_order_relaxed) < i_bufferSize) return false;

		ElemT* pos = o_buffer;
		size_t sizeLeft = i_bufferSize;

		while (sizeLeft){

			size_t dummy = 0, continuousCount = 0;
			privateReaderGetReadableCount(&dummy, &continuousCount);

			if (continuousCount >= sizeLeft){
				privateReaderContinuousPop(pos, sizeLeft);

				pos += sizeLeft;
				sizeLeft = 0;
			}
			else{

				privateReaderContinuousPop(pos, continuousCount);

				pos += continuousCount;
				sizeLeft -= continuousCount;
			}
		}

		return true;
	}

	/**
	 * For wirting thread only
	 */
	void WriterGetWritableCount(size_t* o_total){
	    _LightWeightMutexLockGuard<std::memory_order_seq_cst> guard(writerMutex);
        privateWriterGetWritableCount(o_total,nullptr);
	}

	/**
	 * For wirting thread only
	 */
	bool WriterPush(ElemT const * const i_buffer, size_t const i_bufferSize){
        _LightWeightMutexLockGuard<std::memory_order_seq_cst> guard(writerMutex);

		if ((this->capacity - this->readableCount.load(std::memory_order_relaxed)) < i_bufferSize) return false;

		ElemT const * pos = i_buffer;
		size_t sizeLeft = i_bufferSize;

		while (sizeLeft){

			size_t dummy = 0, continuousCount = 0;
			this->privateWriterGetWritableCount(&dummy, &continuousCount);

			if (continuousCount >= sizeLeft){

				this->privateWriterContinuousPush(pos, sizeLeft);

				pos += sizeLeft;
				sizeLeft = 0;
			}
			else{

				this->privateWriterContinuousPush(pos, continuousCount);

				pos += continuousCount;
				sizeLeft -= continuousCount;
			}
		}

		return true;
	}
};

}} // namespace rlib::lockfree

#ifdef RLF_CYCLEBUFFERSWSR_TESTER

#include <iostream>
#include <thread>
#include <string>
#include <condition_variable>
#include <sstream>
#include <chrono>

namespace rlf{

using namespace std;

class CycleBufferSwsr::Tester{
public:
	static void PrintBuffer(CycleBufferSwsr& buffer){
		cout << "printing buffer:" << endl;
		// cout << "[" << buffer.buffer.get() << "]" << endl;

		ostringstream line1;
		ostringstream line2;
		ostringstream line3;
		ostringstream line4;
		ostringstream line5;

		line1 << "content   :";
		line2 << "ascii     :";
		line3 << "read pos  :";
		line4 << "write pos :";
		line5 << "readable  :";

		for (size_t i = 0; i < buffer.capacity; ++i){

			unsigned char val = (unsigned char)(buffer.buffer[i]);

			line1 << " ";
			line1 << hex << int(val % 16) << int(val / 16);

			char ascii = ' ';

			if (isprint(val)){
				ascii = buffer.buffer[i];
			}
			line2 << " " << ascii << " ";

			if (buffer.readPos == i){
				line3 << " * ";
			}
			else{
				line3 << "   ";
			}

			if (buffer.writePos == i){
				line4 << " * ";
			}
			else{
				line4 << "   ";
			}

			if (buffer.readableCount + buffer.readPos >= buffer.capacity){
				if ((i >= buffer.readPos) || (i < (buffer.readPos + buffer.readableCount) % buffer.capacity)){
					line5 << " * ";
				}
				else{
					line5 << "   ";
				}
			}
			else if (((i >= buffer.readPos) && (i < (buffer.readPos + buffer.readableCount)))) {
				line5 << " * ";
			}
			else{
				line5 << "   ";
			}

		}

		cout
			<< line1.str() << endl
			<< line2.str() << endl
			<< line3.str() << endl
			<< line4.str() << endl
			<< line5.str() << endl;

		cout << "cnt       :" << buffer.readableCount << endl;

		cout << endl;


	}

	static void ReadSome(CycleBufferSwsr& buffer){
		cin.clear();
		cout << "Enter the read count:";
		int readCnt;
		cin >> readCnt;
		unique_ptr<char[]> readBuf(new char[readCnt + 1]);
		readBuf[readCnt] = 0;

		bool success = buffer.ReaderPop(readBuf.get(), readCnt);
		cout << "result:" << (success ? "success" : "failed") << endl;
		cout << "read: [" << readBuf.get() << "]" << endl;
	}

	static void WriteSome(CycleBufferSwsr& buffer){
		cin.clear();
		cout << "Enter characters to write:";
		std::string toWrite;
		cin >> toWrite;
		bool success = buffer.WriterPush(toWrite.c_str(), toWrite.length());
		cout << "Write cout:" << toWrite.length() << ", result:" << (success ? "success" : "failed") << endl;
	}

	static void Entry(){
		CycleBufferSwsr buff;
		buff.ReInit(10);
		while (1){
			cin.clear();
			cout << "what do you want? 1 for write, 2 for read, and 3 for print, and 4 for exit.";
			int cmd;
			cin >> cmd;
			switch (cmd){
			case 1: CycleBufferSwsr::Tester::WriteSome(buff); break;
			case 2: CycleBufferSwsr::Tester::ReadSome(buff); break;
			case 3: CycleBufferSwsr::Tester::PrintBuffer(buff); break;
			}
			if (cmd == 4)
				break;
		}
	}
};

}

#endif // RLF_CYCLEBUFFERSWSR_TESTER


#if 0 // logic test

#define RLF_CYCLEBUFFERSWSR_TESTER
#include "rlf/CycleBufferSwsr.h"
using namespace rlf;

int main()
{
    CycleBufferSwsr::Tester::Entry();
    return 0;
}

#endif


#if 0 // performance test

#include "rlf/CycleBufferSwsr.h"
#include "rlf/_LightWeightMutex.h"
using namespace rlf;

#include <thread>
#include <mutex>
#include <iostream>
#include <chrono>
using namespace std;


void CycleBufferSwsrPerformanceTest(){
    size_t cnt = 3000000;
    {
        rlf::CycleBufferSwsr buffer(2*cnt);
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
        rlf::CycleBufferSwsr buffer(2*cnt);
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
        rlf::CycleBufferSwsr buffer(2*cnt);
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
        rlf::CycleBufferSwsr buffer(2*cnt);
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

#endif


#endif
