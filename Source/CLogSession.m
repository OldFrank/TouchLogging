//
//  CLogSession.m
//  TouchLogging
//
//  Created by Jonathan Wight on 10/13/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CLogSession.h"

@implementation CLogSession

@synthesize parentSession;
@synthesize identifier;
@synthesize started;

- (id)initWithParentSession:(CLogSession *)inParentSession identifier:(NSString *)inIdentifier
    {
    if ((self = [super init]) != NULL)
        {
        parentSession = inParentSession;
        identifier = inIdentifier;
        started = [NSDate date];
        }
    return(self);
    }

@end
