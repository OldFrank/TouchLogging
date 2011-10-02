//
//  CLogEvent.h
//  TouchCode
//
//  Created by Jonathan Wight on 10/13/10.
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
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
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

typedef enum {
	LoggingLevel_EMERG = 0,
	LoggingLevel_ALERT = 1,
	LoggingLevel_CRIT = 2,
	LoggingLevel_ERR = 3,
	LoggingLevel_WARNING = 4,
	LoggingLevel_NOTICE = 5,
	LoggingLevel_INFO = 6,
	LoggingLevel_DEBUG = 7,
} ELoggingLevel;

@class CLogSession;

@interface CLogEvent : NSObject {
}

@property (readwrite, nonatomic, retain) CLogSession *session;
@property (readwrite, nonatomic, assign) NSInteger level;
@property (readwrite, nonatomic, retain) NSDate *timestamp;
@property (readwrite, nonatomic, retain) NSString *sender;
@property (readwrite, nonatomic, retain) NSString *facility;
@property (readwrite, nonatomic, retain) NSString *message;
@property (readwrite, nonatomic, retain) NSDictionary *userInfo;

+ (NSString *)stringForLevel:(NSInteger)inLevel;

@end
