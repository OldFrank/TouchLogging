//
//  CLogging.h
//  TouchCode
//
//  Created by Jonathan Wight on 3/24/07.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#include <stdarg.h>

#import "CLogEvent.h"
#import "CLogSession.h"
#import "FileFunctionLine.h"

@class CLogEvent;

@protocol CLoggingDestination;

extern NSString *kLogSenderKey;
extern NSString *kLogFacilityKey;
extern NSString *kLogOnceKey;
extern NSString *kLogFileKey;
extern NSString *kLogFunctionKey;
extern NSString *kLogLineKey;

@interface CLogging : NSObject {
}

@property (readwrite, atomic, assign) BOOL enabled;
@property (readwrite, atomic, copy) NSString *sender;
@property (readwrite, atomic, copy) NSString *facility;
@property (readonly, atomic, retain) NSMutableArray *sessions;
@property (readwrite, atomic, retain) NSMutableArray *destinations;

/** Returns the thread's logging instance */
+ (CLogging *)sharedInstance;

- (void)addDefaultDestinations;
- (void)addDestination:(id <CLoggingDestination>)inHandler;
- (void)removeDestination:(id <CLoggingDestination>)inHandler;

- (void)startSession:(NSString *)inIdentifier;
- (void)endSession;

/// Logging.
- (void)logEvent:(CLogEvent *)inLogEvent;

- (void)logLevel:(int)inLevel format:(NSString *)inFormat, ...;
- (void)logLevel:(int)inLevel userInfo:(NSDictionary *)inDictionary messageFormat:(NSString *)inFormat, ...;
- (void)logLevel:(int)inLevel fileFunctionLine:(SFileFunctionLine)inFileFunctionLine userInfo:(NSDictionary *)inDictionary messageFormat:(NSString *)inFormat, ...;

- (void)logError:(NSError *)inError;
- (void)logException:(NSException *)inException;

+ (NSString *)nameForLevel:(int)inLevel;

@end

#pragma mark -

@protocol CLoggingDestination <NSObject>

@optional
- (BOOL)loggingDidStart:(CLogging *)inLogging;
- (BOOL)loggingDidEnd:(CLogging *)inLogging;

@required
- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;

@end

#pragma mark -

#ifndef LOGGING
#define LOGGING 1
#endif

#if LOGGING == 1

#define Log_(level, ...) \
	do \
		{ \
		[[CLogging sharedInstance] logLevel:(level) fileFunctionLine:FileFunctionLine_() userInfo:NULL messageFormat:__VA_ARGS__]; \
		} \
	while (0)

#define LogDict_(level, dict, ...) \
	do \
		{ \
		[[CLogging sharedInstance] logLevel:(level) fileFunctionLine:FileFunctionLine_() userInfo:dict messageFormat:__VA_ARGS__]; \
		} \
	while (0)

#define LogEmergency_(...) Log_(LoggingLevel_EMERG, __VA_ARGS__)
#define LogAlert_(...) Log_(LoggingLevel_ALERT, __VA_ARGS__)
#define LogCritical_(...) Log_(LoggingLevel_CRIT, __VA_ARGS__)
#define LogError_(...) Log_(LoggingLevel_ERR, __VA_ARGS__)
#define LogErr_(...) Log_(LoggingLevel_ERR, __VA_ARGS__)
#define LogWarning_(...) Log_(LoggingLevel_WARNING, __VA_ARGS__)
#define LogWarn_(...) Log_(LoggingLevel_WARNING, __VA_ARGS__)
#define LogNotice_(...) Log_(LoggingLevel_NOTICE, __VA_ARGS__)
#define LogInformation_(...) Log_(LoggingLevel_INFO, __VA_ARGS__)
#define LogInfo_(...) Log_(LoggingLevel_INFO, __VA_ARGS__)
#define LogDebug_(...) Log_(LoggingLevel_DEBUG, __VA_ARGS__)

#define LogOnce_(level, ...) LogDict_(level, [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kLogOnceKey], __VA_ARGS__)
    
#else

#define Log_(level, ...)
#define LogDict_(level, dict, ...)
#define LogEmergency_(...)
#define LogAlert_(...)
#define LogCritical_(...)
#define LogError_(...)
#define LogWarning_(...)
#define LogNotice_(...)
#define LogInformation_(...)
#define LogDebug_(...)

#define LogOnce_(level, ...)

#endif /* LOGGING == 1 */
