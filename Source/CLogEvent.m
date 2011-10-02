//
//  CLogEvent.m
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

#import "CLogEvent.h"

#import "CLogSession.h"

@implementation CLogEvent

@synthesize session;
@synthesize level;
@synthesize timestamp;
@synthesize sender;
@synthesize facility;
@synthesize message;
@synthesize userInfo;

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (session:%@, timestamp:%@, sender:%@, facility:%@, message:%@ userInfo:%@", [super description], self.session, self.timestamp, self.sender, self.facility, self.message, self.userInfo]);
    }

+ (NSString *)stringForLevel:(NSInteger)inLevel;
    {
    switch (inLevel)
        {
        case LoggingLevel_EMERG:
            return(@"Emergency");
        case LoggingLevel_ALERT:
            return(@"Alert");
        case LoggingLevel_CRIT:
            return(@"Critcial");
        case LoggingLevel_ERR:
            return(@"Error");
        case LoggingLevel_WARNING:
            return(@"Warning");
        case LoggingLevel_NOTICE:
            return(@"Notice");
        case LoggingLevel_INFO:
            return(@"Info");
        case LoggingLevel_DEBUG:
            return(@"Debug");
        default:
            return([NSString stringWithFormat:@"%d", inLevel]);
        }
    }

@end
