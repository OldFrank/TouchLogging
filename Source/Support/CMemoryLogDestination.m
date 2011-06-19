//
//  CMemoryLogDestination.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 06/18/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CMemoryLogDestination.h"

@interface CMemoryLogDestination ()
@property (readwrite, nonatomic, retain) NSMutableArray *mutableEvents;
@end

@implementation CMemoryLogDestination

@synthesize mutableEvents;

static CMemoryLogDestination *gSharedInstance = NULL;

+ (CMemoryLogDestination *)sharedInstance
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        gSharedInstance = [[CMemoryLogDestination alloc] init];
        });
    return(gSharedInstance);
    }

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        mutableEvents = [[NSMutableArray alloc] init];
		}
	return(self);
	}

- (NSArray *)events
    {
    return(self.mutableEvents);
    }

- (BOOL)logging:(CLogging *)inLogging didLogEvent:(CLogEvent *)inEvent;
    {
    NSIndexSet *theIndexSet = [NSIndexSet indexSetWithIndex:[self.mutableEvents count]];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:theIndexSet forKey:@"events"];
    [self.mutableEvents addObject:inEvent];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:theIndexSet forKey:@"events"];
    return(YES);
    }

@end
