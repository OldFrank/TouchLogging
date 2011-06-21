//
//  CFileHandleLoggingDestination.h
//  AnythingBucket
//
//  Created by Jonathan Wight on 06/20/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLogging.h"

@interface CFileHandleLoggingDestination : NSObject <CLoggingDestination>

@property (readwrite, nonatomic, retain) NSFileHandle *fileHandle;
@property (readwrite, nonatomic, copy) NSData *(^block)(CLogEvent *inEvent);

- (id)initWithFileHandle:(NSFileHandle *)inFileHandle;

@end
