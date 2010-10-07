//
//  CLogging.m
//  TouchCode
//
//  Created by Jonathan Wight on 3/24/07.
//  Copyright 2009 Small Society. All rights reserved.
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

#import "CLogging.h"

#import "CBetterCoreDataManager.h"

static CLogging *gInstance = NULL;

@interface CLogging () <CCoreDataManagerDelegate>
@property (readwrite, assign) BOOL started;

- (void)start;
- (void)end;
@end

#pragma mark -

@implementation CLogging

@synthesize enabled;
@synthesize flags;
@synthesize sender;
@synthesize facility;
@synthesize loggingDestination;
@synthesize handlers;
@synthesize started;

+ (CLogging *)instance
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

    @synchronized(@"CLogging.instance")
        {
        if (gInstance == NULL)
            {
            gInstance = [[CLogging alloc] init];
            }
        }

    [thePool release];

    return(gInstance);
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

        flags = LoggingFlags_WriteToSTDERR;
    //	#if DEBUG_LOGGING_PERSISTANT
        flags |= LoggingFlags_WriteToDatabase;
    //	#endif
        }
    return(self);
    }

- (void)dealloc
    {
    [self end];

    [sender release];
    sender = NULL;
    [facility release];
    facility = NULL;
    [loggingDestination release];
    loggingDestination = NULL;
    [handlers release];
    handlers = NULL;
    //
    [super dealloc];
    }

#pragma mark -

- (CLoggingDestination *)destination
    {
    }

#pragma mark -

- (void)addHandler:(id <CLoggingHandler>)inHandler forEvents:(NSArray *)inEvents;
    {
    if (self.handlers == NULL)
        self.handlers = [NSMutableDictionary dictionary];

    for (NSString *theEvent in inEvents)
        {
        NSMutableArray *theHandlers = [self.handlers objectForKey:theEvent];
        if (theHandlers == NULL)
            {
            theHandlers = [NSMutableArray arrayWithObject:inHandler];
            [self.handlers setObject:theHandlers forKey:theEvent];
            }
        else
            {
            [theHandlers addObject:inHandler];
            }
        }

    if (self.started == YES)
        {
        if ([inEvents containsObject:@"start"])
            {
            [inHandler handleLogging:self event:@"start" error:NULL];
            }
        }
    }

- (void)removeHandler:(id <CLoggingHandler>)inHandler
    {
    for (NSMutableArray *theHandlers in [self.handlers allValues])
        {
        if ([theHandlers containsObject:inHandler])
            [theHandlers removeObject:inHandler];
        }
    }

- (void)start
    {
    NSArray *theHandlers = [self.handlers objectForKey:@"start"];
    for (id <CLoggingHandler> theHandler in theHandlers)
        {
        [theHandler handleLogging:self event:@"start" error:NULL];
        }

    self.started = YES;
    }

- (void)end
    {
    NSArray *theHandlers = [self.handlers objectForKey:@"end"];
    for (id <CLoggingHandler> theHandler in theHandlers)
        {
        [theHandler handleLogging:self event:@"end" error:NULL];
        }
    }

#pragma mark -

- (void)logLevel:(int)inLevel format:(NSString *)inFormat, ...
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessage = [[[NSString alloc] initWithFormat:inFormat arguments:theArgList] autorelease];
    va_end(theArgList);

    SFileFunctionLine theFileFunctionLine = { .file = NULL, .function = NULL, .line = 0 };
    [self logLevel:inLevel fileFunctionLine:theFileFunctionLine dictionary:NULL format:@"%@", theMessage];

    [thePool release];
    }

- (void)logLevel:(int)inLevel dictionary:(NSDictionary *)inDictionary format:(NSString *)inFormat, ...;
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessage = [[[NSString alloc] initWithFormat:inFormat arguments:theArgList] autorelease];
    va_end(theArgList);

    SFileFunctionLine theFileFunctionLine = { .file = NULL, .function = NULL, .line = 0 };
    [self logLevel:inLevel fileFunctionLine:theFileFunctionLine dictionary:inDictionary format:@"%@", theMessage];

    [thePool release];
    }

- (void)logLevel:(int)inLevel fileFunctionLine:(SFileFunctionLine)inFileFunctionLine dictionary:(NSDictionary *)inDictionary format:(NSString *)inFormat, ...;
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

    if (self.enabled == NO)
        return;

    if (self.started == NO)
        [self start];


    va_list theArgList;
    va_start(theArgList, inFormat);
    NSString *theMessageString = [[[NSString alloc] initWithFormat:inFormat arguments:theArgList] autorelease];
    va_end(theArgList);

    if (self.flags & LoggingFlags_WriteToSTDERR)
        {
        char *theLevelString = NULL;
        switch (inLevel)
            {
            case LoggingLevel_EMERG:
                theLevelString = "EMERG: ";
                break;
            case LoggingLevel_ALERT:
                theLevelString = "ALERT: ";
                break;
            case LoggingLevel_CRIT:
                theLevelString = "CRIT:  ";
                break;
            case LoggingLevel_ERR:
                theLevelString = "ERROR: ";
                break;
            case LoggingLevel_WARNING:
                theLevelString = "WARN:  ";
                break;
            case LoggingLevel_NOTICE:
                theLevelString = "NOTICE:";
                break;
            case LoggingLevel_INFO:
                theLevelString = "INFO:  ";
                break;
            case LoggingLevel_DEBUG:
                theLevelString = "DEBUG: ";
                break;
            }

        fprintf(stderr, "%s %s\n", theLevelString, [theMessageString UTF8String]);
        }

    if (self.flags & LoggingFlags_WriteToDatabase)
        {
        NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
        
        [theDictionary setObject:[NSNumber numberWithInteger:inLevel] forKey:@"level"];
        [theDictionary setObject:theMessageString forKey:@"message"];
        [theDictionary setObject:[NSDate date] forKey:@"timestamp"];
        [theDictionary setObject:self.sender forKey:@"sender"];
        [theDictionary setObject:self.facility forKey:@"facility"];
//        [theDictionary setObject:self.session forKey:@"session"];
        
        
        if (inDictionary)
            {
            NSData *theAttributesData = [NSPropertyListSerialization dataFromPropertyList:inDictionary format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
            [theDictionary setObject:theAttributesData forKey:@"extraAttributes"];
            }
        
        
        [self.destination logDictionary:theDictionary];

        NSArray *theHandlers = [self.handlers objectForKey:@"log"];
        for (id <CLoggingHandler> theHandler in theHandlers)
            {
            [theHandler handleLogging:self event:@"log" error:NULL];
            }
        }

    [thePool release];
    }

#pragma mark -

- (void)logError:(NSError *)inError
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

    NSDictionary *theUserInfo = [inError userInfo];

    int theLevel = LoggingLevel_ERR;
    NSNumber *theLevelValue = [theUserInfo objectForKey:@"level"];
    if (theLevelValue != NULL)
        theLevel = [theLevelValue intValue];

    NSMutableDictionary *theDictionary = [NSMutableDictionary dictionaryWithDictionary:theUserInfo];
    [theDictionary setObject:[inError domain] forKey:@"domain"];
    [theDictionary setObject:[NSNumber numberWithInteger:[inError code]] forKey:@"code"];
    if ([inError localizedDescription] != NULL)
        [theDictionary setObject:[inError localizedDescription] forKey:@"localizedDescription"];
    if ([inError localizedFailureReason] != NULL)
        [theDictionary setObject:[inError localizedFailureReason] forKey:@"localizedFailureReason"];
    if ([inError localizedRecoverySuggestion] != NULL)
        [theDictionary setObject:[inError localizedRecoverySuggestion] forKey:@"localizedRecoverySuggestion"];

    [self logLevel:theLevel dictionary:theDictionary format:@"%@", [inError localizedDescription]];

    [thePool release];
    }

- (void)logException:(NSException *)inException
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

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

        [self logLevel:theLevel dictionary:theDictionary format:@"%@", [inException reason]];
        }

    [thePool release];
    }

@end

#pragma mark -

@implementation NSError (NSError_LogExtensions)

- (void)log
    {
    #if LOGGING == 1
    [[CLogging instance] logError:self];
    #endif /* LOGGING == 1 */
    }

@end

#pragma mark -

@implementation NSException (NSException_LogExtensions)

- (void)log
    {
    #if LOGGING == 1
    [[CLogging instance] logException:self];
    #endif /* LOGGING == 1 */
    }

@end
