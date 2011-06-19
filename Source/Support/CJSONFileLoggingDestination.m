//
//  CJSONFileLoggingDestination.m
//  AnythingBucket
//
//  Created by Jonathan Wight on 06/18/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CJSONFileLoggingDestination.h"

#import "CFilteringJSONSerializer.h"
#import "CLogEvent.h"
#import "NSDate_InternetDateExtensions.h"

@implementation CJSONFileLoggingDestination

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
		CFilteringJSONSerializer *theSerializer = (id)[CFilteringJSONSerializer serializer];
		theSerializer.convertersByName = [NSDictionary dictionaryWithObjectsAndKeys:
			[^(NSDate *inDate) { return((id)[inDate ISO8601String]); } copy], @"date",
			NULL];
		theSerializer.tests = [NSSet setWithObjects:
			[^(id inObject) { return([inObject isKindOfClass:[NSDate class]] ? @"date" : NULL); } copy],
			NULL];
			
        self.initialData = [@"[\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.block= ^(CLogEvent *inEvent) {
            NSMutableData *theData = [[theSerializer serializeDictionary:[inEvent asDictionary] error:NULL] mutableCopy];
            [theData appendData:[@",\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            return(theData);
            };
        self.terminalData = [@"]\n" dataUsingEncoding:NSUTF8StringEncoding];
		}
	return(self);
	}

@end
