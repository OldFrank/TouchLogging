//
//  CFileHandleLoggingDestination.m
//  TouchLogging
//
//  Created by Jonathan Wight on 10/13/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CFileHandleLoggingDestination.h"

#include <fcntl.h>
#include <unistd.h>

@interface CFileHandleLoggingDestination ()
@property (readwrite, nonatomic, assign) int fileDescriptor;
@end

#pragma mark -

@implementation CFileHandleLoggingDestination

@synthesize URL;
@synthesize fileHandle;
@synthesize fileDescriptor;
@synthesize synchronizeOnWrite;
@synthesize block;
@synthesize initialData;
@synthesize terminalData;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        synchronizeOnWrite = YES;
        block = ^(CLogEvent *inEvent) {
            char *theLevelString = NULL;
            switch (inEvent.level)
                {
                case LoggingLevel_EMERG:
                    theLevelString = "EMERG";
                    break;
                case LoggingLevel_ALERT:
                    theLevelString = "ALERT";
                    break;
                case LoggingLevel_CRIT:
                    theLevelString = "CRIT";
                    break;
                case LoggingLevel_ERR:
                    theLevelString = "ERROR";
                    break;
                case LoggingLevel_WARNING:
                    theLevelString = "WARN";
                    break;
                case LoggingLevel_NOTICE:
                    theLevelString = "NOTICE";
                    break;
                case LoggingLevel_INFO:
                    theLevelString = "INFO";
                    break;
                case LoggingLevel_DEBUG:
                    theLevelString = "DEBUG";
                    break;
                }
                
            NSTimeInterval theInterval = [inEvent.timestamp timeIntervalSinceDate:inEvent.session.started];    
            
            NSString *theString = [NSString stringWithFormat:@"%-6s: %8.3f : %@\n", theLevelString, theInterval, inEvent.message];
            NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
            return(theData);
            };

		}
	return(self);
	}


- (id)initWithURL:(NSURL *)inURL;
    {
    if ((self = [self init]) != NULL)
        {
        URL = inURL;
        
        fileDescriptor = open([[inURL path] UTF8String], O_RDWR | O_CREAT);
        if (fileDescriptor < 0)
            {
            NSLog(@"ERROR");
            }
            
        off_t theOffset = lseek(fileDescriptor, 0, SEEK_END);
		if (theOffset < 0)
            {
            NSLog(@"ERROR");
            }
        else if (theOffset == 0)
            {
            if (self.initialData.length > 0)
                {
                if (write(fileDescriptor, [self.initialData bytes], self.initialData.length) < 0)
                    {
                    NSLog(@"FAILURE");
                    }
                }
            if (self.terminalData.length > 0)
                {
                if (write(fileDescriptor, [self.terminalData bytes], self.terminalData.length) < 0)
                    {
                    NSLog(@"FAILURE");
                    }
                }

            if (self.synchronizeOnWrite)
                {
                if (fsync(self.fileDescriptor) < 0)
                    {
                    NSLog(@"Error");
                    }
                }
            }
        }
    return(self);
    }
    
- (id)initWithFileHandle:(NSFileHandle *)inFileHandle;
    {
    if ((self = [self init]) != NULL)
        {
        fileHandle = inFileHandle;
        
        fileDescriptor = [inFileHandle fileDescriptor];
        }
    return(self);
    }
    
- (void)dealloc
    {
    if (fileHandle == NULL)
        {
        close(fileDescriptor);
        }

    fileDescriptor = -1;
    }
    
- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;
    {
    NSData *theData = NULL;
    
    if (self.block)
        {
        theData = self.block(inEvent);
        }

    if (theData != NULL)
        {
        NSData *theTerminalData = self.terminalData;
        off_t theTerminalDataLength = theTerminalData.length;
        
        if (theTerminalData.length > 0)
            {
            off_t theOffset = lseek(self.fileDescriptor, -theTerminalDataLength, SEEK_END);
            if (theOffset < 0)
                {
                NSLog(@"ERROR");
                }
            }
        
        if (theData.length > 0)
            {
            if (write(self.fileDescriptor, [theData bytes], [theData length]) < 0)
                {
                NSLog(@"FAILURE");
                }
            }

        if (theTerminalDataLength > 0)
            {
            if (write(self.fileDescriptor, [theTerminalData bytes], theTerminalDataLength) < 0)
                {
                NSLog(@"FAILURE");
                }
            }
            
        if (self.synchronizeOnWrite)
            {
            if (fsync(self.fileDescriptor) < 0)
                {
                NSLog(@"Error");
                }
            }
        }
    
    return(YES);
    }

@end
