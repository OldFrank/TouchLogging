//
//  CFileHandleLoggingDestination.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 06/20/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CFileHandleLoggingDestination.h"

#import "CLogSession.h"

@implementation CFileHandleLoggingDestination

@synthesize fileHandle;
@synthesize block;

- (id)initWithFileHandle:(NSFileHandle *)inFileHandle
	{
	if ((self = [super init]) != NULL)
		{
        block = ^(CLogEvent *inEvent) {
            NSString *theLevelString = [CLogging nameForLevel:inEvent.level];
            NSTimeInterval theInterval = [inEvent.timestamp timeIntervalSinceDate:inEvent.session.started];    
            
            NSString *theString = [NSString stringWithFormat:@"%-5.5s : %7.3f : %@\n", [theLevelString UTF8String], theInterval, inEvent.message];
            NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
            return(theData);
            };
            
        fileHandle = inFileHandle;
		}
	return(self);
	}

- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;
    {
    NSData *theData = self.block(inEvent);
    [self.fileHandle writeData:theData];
    return(YES);
    }

@end
