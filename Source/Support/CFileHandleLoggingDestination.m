//
//  CFileHandleLoggingDestination.m
//  TouchCode
//
//  Created by Jonathan Wight on 06/20/11.
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

#import "CFileHandleLoggingDestination.h"

#import "CLogSession.h"

@interface CFileHandleLoggingDestination ()
@property (readwrite, nonatomic, copy) CLogEvent *lastEvent;
@property (readwrite, nonatomic, assign) NSInteger repeatCount;
@end

#pragma mark -

@implementation CFileHandleLoggingDestination

@synthesize fileHandle;
@synthesize block;
@synthesize squashRepeats;

@synthesize lastEvent;
@synthesize repeatCount;

- (id)initWithFileHandle:(NSFileHandle *)inFileHandle
	{
	if ((self = [super init]) != NULL)
		{
        __weak CFileHandleLoggingDestination *_self = self;
        block = ^(CLogEvent *inEvent) {
            NSString *theLevelString = [CLogging nameForLevel:inEvent.level];
            NSTimeInterval theInterval = [inEvent.timestamp timeIntervalSinceDate:inEvent.session.started];

            NSString *theString = [NSString stringWithFormat:@"%-5.5s:%6.3f: %@", [theLevelString UTF8String], theInterval, inEvent.message];
            if (_self.repeatCount > 1)
                {
                theString = [theString stringByAppendingFormat:@"(repeated %d times)", _self.repeatCount];
                }
            theString = [theString stringByAppendingString:@"\n"];
            NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
            return(theData);
            };

        fileHandle = inFileHandle;
		}
	return(self);
	}

- (BOOL)loggingDidEnd:(CLogging *)inLogging;
    {
    if (self.lastEvent != NULL && self.repeatCount > 1)
        {
        NSData *theData = self.block(self.lastEvent);
        [self.fileHandle writeData:theData];

        self.lastEvent = NULL;
        }
    return(YES);
    }

- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;
    {
    if (self.squashRepeats == YES && [self.lastEvent.message isEqualToString:inEvent.message])
        {
        self.repeatCount++;
        }
    else
        {
        if (self.repeatCount > 1)
            {
            NSData *theData = self.block(self.lastEvent);
            [self.fileHandle writeData:theData];

            self.repeatCount = 0;
            self.lastEvent = NULL;
            }
        
        NSData *theData = self.block(inEvent);
        [self.fileHandle writeData:theData];
        
        self.lastEvent = inEvent;
        }
    return(YES);
    }

@end
