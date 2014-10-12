#include "rlib/log/LogLine.h"

#include <iosfwd>
using std::streambuf;

#include <string>
using std::string;

#include "rlib/log/LogDispatcher.h"
using rlib::log::LogDispatcher;

namespace rlib{ namespace log {

LogLine::~LogLine(){
	if(!thisLogDone)
		logDispatcher.OnLogLine(*this);
}

}} // namespace rlib::log
