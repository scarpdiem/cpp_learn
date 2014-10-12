#ifndef ROXMA_DEBUG_RLOG_H
#define ROXMA_DEBUG_RLOG_H

#include "rlib/log/LogLine.h"

namespace rlib{ namespace log{

/**
 * @file roxma/debug/LOG.h
 * @see LOG
 * @example debug/LOG.cpp
 */

/**
 * @see LOG
 * @example debug/LOG.cpp
 */
#define LOG_ERROR			LOG(roxma::debug::LogLine::ERROR)
/**
 * @see LOG
 * @example debug/LOG.cpp
 */
#define LOG_WARN			LOG(roxma::debug::LogLine::WARN)
/**
 * @see LOG
 * @example debug/LOG.cpp
 */
#define LOG_INFO			LOG(roxma::debug::LogLine::INFO)

/**
 * An internal macro to use the LogLine class. 
 * @param LogLevel the logging level. See @ref roxma::debug::LogLine::LogLevel 
 *  for more information.
 * @see LOG_ERROR
 * @see LOG_WARN
 * @see LOG_INFO
 * @see @ref roxma::debug::LogLine::LogLevel 
 */
#define LOG(LogLevel)     (roxma::debug::LogLine(LogLevel,__PRETTY_FUNCTION__,__FILE__,__LINE__).GetStringStream())

}}

#endif

