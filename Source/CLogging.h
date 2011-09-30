//
//  CLogging.h
//  TouchCode
//
//  Created by Jonathan Wight on 3/24/07.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import <Foundation/Foundation.h>

#include <stdarg.h>

#import "CLogEvent.h"
#import "CLogSession.h"
#import "FileFunctionLine.h"

@class CLogEvent;

@protocol CLoggingDestination;

@interface CLogging : NSObject {
	BOOL enabled;
	NSString *sender;
	NSString *facility;
    NSMutableArray *sessions;
    NSMutableArray *destinations;
}

@property (readwrite, assign) BOOL enabled;
@property (readwrite, copy) NSString *sender;
@property (readwrite, copy) NSString *facility;
@property (readonly, retain) NSMutableArray *sessions;
@property (readwrite, retain) NSMutableArray *destinations;

/** Returns the thread's logging instance */
+ (CLogging *)sharedInstance;

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
		NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init]; \
		[[CLogging sharedInstance] logLevel:(level) fileFunctionLine:FileFunctionLine_() userInfo:FileFunctionLineDict_() messageFormat:__VA_ARGS__]; \
		[thePool release]; \
		} \
	while (0)

#define LogDict_(level, dict, ...) \
	do \
		{ \
		NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init]; \
		[[CLogging sharedInstance] logLevel:(level) fileFunctionLine:FileFunctionLine_() userInfo:dict messageFormat:__VA_ARGS__]; \
		[thePool release]; \
		} \
	while (0)

#define LogEmergency_(...) Log_(LoggingLevel_EMERG, __VA_ARGS__)
#define LogAlert_(...) Log_(LoggingLevel_ALERT, __VA_ARGS__)
#define LogCritical_(...) Log_(LoggingLevel_CRIT, __VA_ARGS__)
#define LogError_(...) Log_(LoggingLevel_ERR, __VA_ARGS__)
#define LogWarning_(...) Log_(LoggingLevel_WARNING, __VA_ARGS__)
#define LogNotice_(...) Log_(LoggingLevel_NOTICE, __VA_ARGS__)
#define LogInformation_(...) Log_(LoggingLevel_INFO, __VA_ARGS__)
#define LogDebug_(...) Log_(LoggingLevel_DEBUG, __VA_ARGS__)

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

#endif /* LOGGING == 1 */
