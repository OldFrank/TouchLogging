//
//  CFileHandleLoggingDestination.h
//  TouchLogging
//
//  Created by Jonathan Wight on 10/13/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLogging.h"

@interface CFileHandleLoggingDestination : NSObject <CLoggingDestination> {
}

@property (readwrite, nonatomic, retain) NSURL *URL;
@property (readwrite, nonatomic, retain) NSFileHandle *fileHandle;
@property (readwrite, nonatomic, assign) BOOL synchronizeOnWrite;
@property (readwrite, nonatomic, copy) NSData *(^block)(CLogEvent *inEvent);
@property (readwrite, nonatomic, retain) NSData *initialData;
@property (readwrite, nonatomic, retain) NSData *terminalData;

- (id)initWithURL:(NSURL *)inURL;
- (id)initWithFileHandle:(NSFileHandle *)inFileHandle;

@end
