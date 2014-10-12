#include "rlib/log/LogCapture.h"

#include "rlib/log/LogDispatcher.h"
using rlib::log::LogDispatcher;


namespace rlib{ namespace log{
LogCaptureGuard::LogCaptureGuard(
		  const char*			inFileName
		, const char*			inFunctionName
		, size_t				inLineNumber
		, const char*			inPrettyFunction
		, const std::string&	inName
		, const std::string&	inValue
		, LogDispatcher&		inoutDispatcher
	)
		: LogCaptureInfo(inFileName,inFunctionName,inLineNumber, inPrettyFunction, inName, inValue)
		, dispatcher(inoutDispatcher)
	{
		dispatcher.OnLogCaptureInfoPush(*this);
	}

LogCaptureGuard::~LogCaptureGuard(){
	dispatcher.OnLogCaptureInfoPop(*this);
}

}}
