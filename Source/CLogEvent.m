//
//  CLogEvent.m
//  TouchLogging
//
//  Created by Jonathan Wight on 10/13/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

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

- (NSDictionary *)asDictionary;
    {
    NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
    // session
    [theDictionary setObject:[NSNumber numberWithInteger:self.level] forKey:@"level"];
    [theDictionary setObject:self.timestamp forKey:@"timestamp"];
    if (self.sender.length > 0)
        {
        [theDictionary setObject:self.sender forKey:@"sender"];
        }
    if (self.facility.length > 0)
        {
        [theDictionary setObject:self.facility forKey:@"facility"];
        }
    if (self.message.length > 0)
        {
        [theDictionary setObject:self.message forKey:@"message"];
        }
    if (self.userInfo.count > 0)
        {
        [theDictionary setObject:self.userInfo forKey:@"userInfo"];
        }
    
    return([theDictionary copy]);    
    }

@end
