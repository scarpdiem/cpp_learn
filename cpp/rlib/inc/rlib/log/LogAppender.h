#ifndef ROXMA_LOG_LOGAPPENDER_H
#define ROXMA_LOG_LOGAPPENDER_H

#include <stdint.h>

#include <vector>

#include "rlib/log/LogLine.h"
namespace rlib{ namespace log{
	class LogLine;
}}

#include "rlib/log/LogCapture.h"
namespace rlib{ namespace log{
	struct LogCaptureInfo;
}}


namespace rlib{ namespace log{

class LogAppender{
public:
	virtual int32_t OnLogLine(
						  const LogLine& logLine
						, const std::vector<rlib::log::LogCaptureInfo*>& LogCaptures
						, size_t threadId
					) = 0;
	virtual ~LogAppender(){}


};

}}

#endif
