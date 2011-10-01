//
//  CFileHandleLoggingDestination.m
//  Logging
//
//  Created by Jonathan Wight on 10/13/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CFileLoggingDestination.h"

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#import "CLogSession.h"

// TODO -- use GCD io.

@interface CFileLoggingDestination ()
@end

#pragma mark -

@implementation CFileLoggingDestination

@synthesize URL;
@synthesize block;
@synthesize initialData;
@synthesize terminalData;

- (id)init
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
		}
	return(self);
	}

- (id)initWithURL:(NSURL *)inURL;
    {
    if ((self = [self init]) != NULL)
        {
        URL = inURL;
        }
    return(self);
    }
    
- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;
    {    
    NSData *theData = NULL;
    
    if (self.block)
        {
        theData = self.block(inEvent);
        }

    if (theData == NULL)
        {
        return(NO);
        }

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.URL.path] == NO)
        {
        NSError *theError = NULL;
        
        NSMutableData *theMutableData = [NSMutableData data];
        if (self.initialData)
            {
            [theMutableData appendData:self.initialData];
            }
        if (self.terminalData)
            {
            [theMutableData appendData:self.terminalData];
            }
        
        if ([theMutableData writeToURL:self.URL options:0 error:&theError] == NO)
            {
            NSLog(@"Could not create file");
            }
        }

    int theFileDescriptor = open([self.URL.path UTF8String], O_WRONLY);
    
    struct stat theStatBuffer;
    fstat(theFileDescriptor, &theStatBuffer);



    NSData *theTerminalData = self.terminalData;
    const size_t theTerminalDataLength = theTerminalData.length;
    
    off_t theOffset = lseek(theFileDescriptor, theStatBuffer.st_size -theTerminalDataLength, SEEK_SET);
    if (theOffset < 0)
        {
        NSLog(@"Error seeking %d", errno);
        close(theFileDescriptor);
        return(NO);
        }
    
    if (theData.length > 0)
        {
        if (write(theFileDescriptor, [theData bytes], [theData length]) < 0)
            {
            NSLog(@"Error writing %d", errno);
            close(theFileDescriptor);
            return(NO);
            }
        }

    if (theTerminalDataLength > 0)
        {
        if (write(theFileDescriptor, [theTerminalData bytes], theTerminalDataLength) < 0)
            {
            NSLog(@"Error writing %d", errno);
            close(theFileDescriptor);
            return(NO);
            }
        }

    close(theFileDescriptor);
    
    return(YES);
    }

@end
