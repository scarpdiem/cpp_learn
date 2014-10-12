#ifndef ROXMA_LOG_LOGDISPATCHER
#define ROXMA_LOG_LOGDISPATCHER

#include <stdint.h>
// type size_t

#include "rlib/log/LogLine.h"
namespace rlib{ namespace log{
	class LogLine;
}}

#include "rlib/log/LogAppender.h"

#include "rlib/log/LogCapture.h"
namespace rlib{ namespace log{
	class LogCaptureInfo;
}}

#include <string>

namespace rlib { namespace log{

class LogDispatcher{

public:

	/**
	 * Handle a LogLine event, this function is thread safe.
	 */
	virtual void OnLogLine(const rlib::log::LogLine& logLine);
	
	/**
	 * Handle a LogCapture push event, this function is thread safe.
	 */
	virtual void OnLogCaptureInfoPush(const LogCaptureInfo& inLogCaptureInfo);

	/**
	 *
	 */
	virtual void OnLogCaptureInfoPop(const LogCaptureInfo& outLogCaptureInfo);
	
	virtual size_t GetAppenderCount()				{ return 0;				}
	virtual LogAppender* GetAppender(size_t index)	{ return (LogAppender*)0;	}

	virtual ~LogDispatcher();
};

}}

#endif
