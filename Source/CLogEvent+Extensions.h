//
//  CLogEvent+Extensions.h
//  knotes
//
//  Created by Jonathan Wight on 9/30/11.
//  Copyright (c) 2011 knotes. All rights reserved.
//

#import "CLogEvent.h"

@interface CLogEvent (Extensions)

- (NSDictionary *)asDictionary;
- (NSData *)asJSON;

@end
