//
//  CLogging.m
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

#import "CLogging.h"

#import "CFileLoggingDestination.h"
#import "CFileHandleLoggingDestination.h"
#import "CLogSession.h"
#import "CLogEvent_Extensions.h"
#import "CJSONFileLoggingDestination.h"

NSString *kLogSenderKey = @"sender";
NSString *kLogFacilityKey = @"facility";
NSString *kLogOnceKey = @"once";
NSString *kLogFileKey = @"file";
NSString *kLogFunctionKey = @"function";
NSString *kLogLineKey = @"line";

static CLogging *gSharedInstance = NULL;

@interface CLogging ()
@property (readwrite, nonatomic, strong) NSMutableSet *oneShotEvents;
@end

#pragma mark -

@implementation CLogging

@synthesize enabled;
@synthesize sender;
@synthesize facility;
@synthesize sessions;
@synthesize destinations;

@synthesize oneShotEvents;

+ (CLogging *)sharedInstance
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        gSharedInstance = [[CLogging alloc] init];
        });
    return(gSharedInstance);
    }

#pragma mark -

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        NSNumber *theEnabledFlag = [[[NSProcessInfo processInfo] environment] objectForKey:@"LOGGING"];
        if (theEnabledFlag)
            enabled = [theEnabledFlag boolValue];
        else
            enabled = YES;

        sessions = [[NSMutableArray alloc] init];
        oneShotEvents = [[NSMutableSet alloc] init];
        }
    return(self);
    }

- (void)dealloc
    {
    [self endSession];
    }

#pragma mark -

- (void)addDefaultDestinations
    {
    CFileHandleLoggingDestination *theStderrLog = [[CFileHandleLoggingDestination alloc] initWithFileHandle:[NSFileHandle fileHandleWithStandardError]];
    theStderrLog.squashRepeats = YES;
    
    [self addDestination:theStderrLog];

    // #########################################################################

    NSError *theError = NULL;
    NSURL *theLogDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:0 create:YES error:&theError];
    
    theLogDirectoryURL = [theLogDirectoryURL URLByAppendingPathComponent:@"Logs" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:theLogDirectoryURL withIntermediateDirectories:YES attributes:NULL error:&theError];
    
    NSURL *theLogFileURL = [theLogDirectoryURL URLByAppendingPathComponent:@"log.json"];
    
    CJSONFileLoggingDestination *theFileLoggingDestination = [[CJSONFileLoggingDestination alloc] initWithURL:theLogFileURL];
    
    [self addDestination:theFileLoggingDestination];
    }

- (void)addDestination:(id <CLoggingDestination>)inHandler
    {
    if (inHandler == NULL)
        {
        return;
        }

    if (self.destinations == NULL)
        self.destinations = [NSMutableArray array];

    [self.destinations addObject:inHandler];

    if (self.sessions.count > 0)
        {
        if ([inHandler respondsToSelector:@selector(loggingDidStart:)])
            {
            [inHandler loggingDidStart:self];
            }
        }
    }

- (void)removeDestination:(id <CLoggingDestination>)inHandler
    {
    [self.destinations removeObject:inHandler];
    }

- (void)startSession:(NSString *)inIdentifier
    {
    [self.sessions addObject:[[CLogSession alloc] initWithParentSession:[self.sessions lastObject] identifier:inIdentifier]];

    for (id <CLoggingDestination> theHandler in self.destinations)
        {
        if ([theHandler respondsToSelector:@selector(loggingDidStart:)])
            {
            [theHandler loggingDidStart:self];
            }
        }
    }

- (void)endSession
    {
    for (id <CLoggingDestination> theHandler in self.destinations)
        {
        if ([theHandler respondsToSelector:@selector(loggingDidEnd:)])
            {
            [theHandler loggingDidEnd:self];
            }
        }

    [self.sessions removeLastObject];
    }

#pragma mark -

- (void)logEvent:(CLogEvent *)inLogEvent;
    {
    if (self.enabled == NO)
        return;
        
    if ([[inLogEvent.userInfo objectForKey:kLogOnceKey] boolValue] == YES)
        {
        if ([self.oneShotEvents containsObject:inLogEvent.message])
            {
            return;
            }
        [self.oneShotEvents addObject:inLogEvent.message];
        }

    if (self.sessions.count == 0)
        {
        [self startSession:@"root"];
        }
        

    inLogEvent.session = [self.sessions lastObject];
    inLogEvent.timestamp = [NSDate date];
    
    if (inLogEvent.sender == NULL)
        inLogEvent.sender = self.sender;
    if (inLogEvent.facility == NULL)
        inLogEvent.facility = self.facility;

    for (id <CLoggingDestination> theHandler in self.destinations)
        {
        [theHandler logging:self didLogEvent:inLogEvent];
        }
    }
    
#pragma mark -

- (void)logLevel:(int)inLevel format:(NSString *)inFormat, ...
    {
    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessage = [[NSString alloc] initWithFormat:inFormat arguments:theArgList];
    va_end(theArgList);

    CLogEvent *theEvent = [[CLogEvent alloc] init];
    theEvent.level = inLevel;
    theEvent.message = theMessage;
        
    [self logEvent:theEvent];
    }

- (void)logLevel:(int)inLevel userInfo:(NSDictionary *)inUserInfo messageFormat:(NSString *)inFormat, ...;
    {
    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessage = [[NSString alloc] initWithFormat:inFormat arguments:theArgList];
    va_end(theArgList);

    CLogEvent *theEvent = [[CLogEvent alloc] init];
    theEvent.level = inLevel;
    theEvent.message = theMessage;
    theEvent.userInfo = inUserInfo;

    [self logEvent:theEvent];
    }

- (void)logLevel:(int)inLevel fileFunctionLine:(SFileFunctionLine)inFileFunctionLine userInfo:(NSDictionary *)inUserInfo messageFormat:(NSString *)inFormat, ...;
    {
    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessageString = [[NSString alloc] initWithFormat:inFormat arguments:theArgList];
    va_end(theArgList);

    NSMutableDictionary *theUserInfo = [inUserInfo mutableCopy];
    [theUserInfo setObject:[NSString stringWithUTF8String:inFileFunctionLine.file] forKey:kLogFileKey];
    [theUserInfo setObject:[NSString stringWithUTF8String:inFileFunctionLine.function] forKey:kLogFunctionKey];
    [theUserInfo setObject:[NSNumber numberWithInt:inFileFunctionLine.line] forKey:kLogLineKey];

    CLogEvent *theEvent = [[CLogEvent alloc] init];
    theEvent.level = inLevel;
    theEvent.message = theMessageString;

    NSString *theFacility = [theUserInfo objectForKey:kLogFacilityKey];
    if (theFacility)
        {
        theEvent.facility = theFacility;
        [theUserInfo removeObjectForKey:kLogFacilityKey];
        }

    NSString *theSender = [theUserInfo objectForKey:kLogSenderKey];
    if (theSender)
        {
        theEvent.sender = theSender;
        [theUserInfo removeObjectForKey:kLogSenderKey];
        }

    theEvent.userInfo = theUserInfo;

    [self logEvent:theEvent];
    }

+ (NSString *)nameForLevel:(int)inLevel;
    {
    NSString *theLevelString = NULL;
    switch (inLevel)
        {
        case LoggingLevel_EMERG:
            theLevelString = @"EMERG";
            break;
        case LoggingLevel_ALERT:
            theLevelString = @"ALERT";
            break;
        case LoggingLevel_CRIT:
            theLevelString = @"CRIT";
            break;
        case LoggingLevel_ERR:
            theLevelString = @"ERROR";
            break;
        case LoggingLevel_WARNING:
            theLevelString = @"WARN";
            break;
        case LoggingLevel_NOTICE:
            theLevelString = @"NOTICE";
            break;
        case LoggingLevel_INFO:
            theLevelString = @"INFO";
            break;
        case LoggingLevel_DEBUG:
            theLevelString = @"DEBUG";
            break;
        }
    return(theLevelString);
    }

#pragma mark -

- (void)logError:(NSError *)inError
    {
    NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionaryWithDictionary:inError.userInfo];
    [theUserInfo setObject:[inError domain] forKey:@"domain"];
    [theUserInfo setObject:[NSNumber numberWithInteger:[inError code]] forKey:@"code"];
    if ([inError localizedDescription] != NULL)
        [theUserInfo setObject:[inError localizedDescription] forKey:@"localizedDescription"];
    if ([inError localizedFailureReason] != NULL)
        [theUserInfo setObject:[inError localizedFailureReason] forKey:@"localizedFailureReason"];
    if ([inError localizedRecoverySuggestion] != NULL)
        [theUserInfo setObject:[inError localizedRecoverySuggestion] forKey:@"localizedRecoverySuggestion"];

    CLogEvent *theEvent = [[CLogEvent alloc] init];

    theEvent.level = LoggingLevel_ERR;
    NSNumber *theLevelValue = [inError.userInfo objectForKey:@"level"];
    if (theLevelValue != NULL)
        {
        theEvent.level = [theLevelValue intValue];
        }
    theEvent.message = [inError localizedDescription];
    theEvent.userInfo = theUserInfo;

    [self logEvent:theEvent];
    }

- (void)logException:(NSException *)inException
    {
    if ([inException.userInfo objectForKey:@"error"] != NULL)
        [self logError:[inException.userInfo objectForKey:@"error"]];
    else
        {
        NSDictionary *theUserInfo = [inException userInfo];

        NSMutableDictionary *theDictionary = [NSMutableDictionary dictionaryWithDictionary:theUserInfo];
        [theDictionary setObject:[inException name] forKey:@"name"];
        [theDictionary setObject:[inException reason] forKey:@"reason"];

        int theLevel = LoggingLevel_ERR;
        NSNumber *theLevelValue = [theUserInfo objectForKey:@"level"];
        if (theLevelValue != NULL)
            theLevel = [theLevelValue intValue];

        [self logLevel:theLevel userInfo:theDictionary messageFormat:@"%@", [inException reason]];
        }
    }

@end
