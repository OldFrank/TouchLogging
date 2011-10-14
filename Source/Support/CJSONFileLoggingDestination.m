//
//  CJSONFileLoggingDestination.m
//  TouchCode
//
//  Created by Jonathan Wight on 06/18/11.
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
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
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

#import "CJSONFileLoggingDestination.h"

#import "CFilteringJSONSerializer.h"
#import "CLogEvent.h"
#import "CLogEvent+Extensions.h"
#import "NSDate_InternetDateExtensions.h"

@implementation CJSONFileLoggingDestination

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
		CFilteringJSONSerializer *theSerializer = (id)[CFilteringJSONSerializer serializer];
		theSerializer.tests = [NSSet setWithObjects:
			[^(id inObject) { return([inObject isKindOfClass:[NSDate class]] ? @"date" : NULL); } copy],
			[^(id inObject) { return([inObject isKindOfClass:[NSURL class]] ? @"url" : NULL); } copy],
			[^(id inObject) { return([inObject isKindOfClass:[NSError class]] ? @"error" : NULL); } copy],
			[^(id inObject) { return([inObject respondsToSelector:@selector(asDictionary)] ? @"asDictionary" : NULL); } copy],
			NULL];

		theSerializer.convertersByName = [NSDictionary dictionaryWithObjectsAndKeys:
			[^(NSDate *inDate) { return((id)[inDate ISO8601String]); } copy], @"date",
			[^(NSURL *inURL) { return((id)[inURL absoluteString]); } copy], @"url",
			[^(NSError *inError) { return([NSDictionary dictionaryWithObjectsAndKeys:
                @"NSError", @"type",
                inError.domain, @"domain",
                [NSNumber numberWithInteger:inError.code], @"code",
                inError.userInfo, @"userInfo",
                NULL]); } copy], @"error",
			[^(id obj) { return([obj asDictionary]); } copy], @"asDictionary",
			NULL];

        self.initialData = [@"[\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.block = ^(CLogEvent *inEvent) {
            NSDictionary *theDictionary = [inEvent asDictionary];
            NSError *theError = NULL;
            NSMutableData *theData = [[theSerializer serializeDictionary:theDictionary error:&theError] mutableCopy];
            [theData appendData:[@",\n" dataUsingEncoding:NSUTF8StringEncoding]];
            return(theData);
            };
        self.terminalData = [@"]\n" dataUsingEncoding:NSUTF8StringEncoding];
		}
	return(self);
	}

@end
