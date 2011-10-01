//
//  CLogEvent+Extensions.m
//  knotes
//
//  Created by Jonathan Wight on 9/30/11.
//  Copyright (c) 2011 knotes. All rights reserved.
//

#import "CLogEvent+Extensions.h"

@implementation CLogEvent (Extensions)

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

- (NSData *)asJSON
    {
    NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
    // session
    [theDictionary setObject:[NSNumber numberWithInteger:self.level] forKey:@"level"];
    [theDictionary setObject:[NSNumber numberWithDouble:[self.timestamp timeIntervalSince1970]] forKey:@"timestamp"];
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
        NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
        [self.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([NSJSONSerialization isValidJSONObject:obj])
                {
                [theUserInfo setObject:obj forKey:key];
                }
            else if ([obj respondsToSelector:@selector(asJSON)])
                {
                obj = [obj asJSON];
                [theUserInfo setObject:obj forKey:key];
                }
            }];
        
        [theDictionary setObject:theUserInfo forKey:@"userInfo"];
        }
    

    NSError *theError = NULL;
    NSData *theData = [NSJSONSerialization dataWithJSONObject:theDictionary options:NSJSONWritingPrettyPrinted error:&theError];
    if (theData == NULL)
        {
        fprintf(stderr, "%s", [[theError description] UTF8String]);
        }
    return(theData);
    }

@end
