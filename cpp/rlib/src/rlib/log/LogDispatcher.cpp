#include "rlib/log/LogDispatcher.h"

#include "rlib/log/LogLine.h"
using rlib::log::LogLine;

#include <string>
using std::string;

#include <iostream>
using std::cout;
using std::endl;

namespace rlib{ namespace log{

void LogDispatcher::OnLogLine(const rlib::log::LogLine& logLine){
	if(GetAppenderCount() == 0){
		cout<< "[ "
				<<logLine.GetPrettyFunction()
			<<" ] [ "
				<<logLine.GetFileName()
			<<" "
				<<logLine.GetLineNumber()
			<<" ] "
			<<logLine.GetStringStream().str()
			<<endl;
	}
}

void LogDispatcher::OnLogCaptureInfoPush(const LogCaptureInfo& inLogCaptureInfo){

}

void LogDispatcher::OnLogCaptureInfoPop(const LogCaptureInfo& inLogCaptureInfo){

}

LogDispatcher::~LogDispatcher(){

}

}} // namespace rlib::log
