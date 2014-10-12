#ifndef ROXMA_LOG_LOG_MACRO_MAKER_H
#define ROXMA_LOG_LOG_MACRO_MAKER_H
/*
 * 	roxma::log::LogDispatcher& 	logDispatcher;
	const char * const				fileName;
	const char * const				functionName;
	const std::size_t				lineNumber;
	const int 						level;
	const char * const				prettyFunction;
 */

#define ROXMA_LOG_LOG_MACRO_LOGLINE(LogLine, logDispatcher,level)	\
			(LogLine(logDispatcher,__FILE__,__FUNCTION__,__LINE__,level,__PRETTY_FUNCTION__).GetStringStream())

//#DEFINE ROXMA_LOG_LOG_MACRO_LOGCAPTURE()

#endif
