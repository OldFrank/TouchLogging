//
//  CMemoryLogDestination.h
//  AnythingBucket
//
//  Created by Jonathan Wight on 06/18/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLogging.h"

@interface CMemoryLogDestination : NSObject <CLoggingDestination>

@property (readonly, nonatomic, retain) NSArray *events;

+ (CMemoryLogDestination *)sharedInstance;

@end
