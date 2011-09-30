//
//  CMailLoggingHandler.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/27/09.
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
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
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

#import "CMailLoggingHandler.h"

#import <MessageUI/MessageUI.h>

#import "CBetterCoreDataManager.h"
#import "NSManagedObjectContext_Extensions.h"
#import "CJSONDataSerializer.h"
#import "NSDate_InternetDateExtensions.h"

@interface CMailLoggingHandler ()
@property (readwrite, nonatomic, retain) CLogging *logging;
@property (readwrite, nonatomic, retain) NSArray *sessions;

- (void)doIt;
@end

#pragma mark -

@implementation CMailLoggingHandler

@synthesize predicate;
@synthesize viewController;
@synthesize recipients;
@synthesize subject;
@synthesize body;
@synthesize logging;
@synthesize sessions;

- (id)init
{
if ((self = [super init]) != NULL)
	{
	predicate = [[NSPredicate predicateWithFormat:@"messages.level.@min <= %@", [NSNumber numberWithInteger:LoggingLevel_ERR]] retain];
	}
return(self);
}

- (void)dealloc
{
[predicate release];
predicate = NULL;
[viewController release];
viewController = NULL;
[recipients release];
recipients = NULL;
[subject release];
subject = NULL;
[body release];
body = NULL;
[sessions release];
sessions = NULL;
//
[super dealloc];
}

#pragma mark -

- (BOOL)handleLogging:(CLogging *)inLogging event:(NSString *)inEvent error:(NSError **)outError;
{
NSError *theError = NULL;

NSPredicate *thePredicate = NULL;


NSDate *theLastLogAlertWhen = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreLogging_LastMailLogsAlertWhen"];

NSPredicate *theNonCurrentSessionPredicate = NULL;
if (theLastLogAlertWhen == NULL)
	theNonCurrentSessionPredicate = [NSPredicate predicateWithFormat:@"self != %@", inLogging.session];
else
	theNonCurrentSessionPredicate = [NSPredicate predicateWithFormat:@"self != %@ AND created > %@", inLogging.session, theLastLogAlertWhen];

if (self.predicate == NULL)
	{
	thePredicate = theNonCurrentSessionPredicate;
	}
else
	{
	thePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:theNonCurrentSessionPredicate, self.predicate, NULL]];
	}

NSArray *theSessions = [inLogging.coreDataManager.managedObjectContext fetchObjectsOfEntityForName:@"LoggingSession" predicate:thePredicate error:&theError];

if ([theSessions count] == 0)
	return(YES);

self.logging = inLogging;
self.sessions = [theSessions valueForKey:@"objectID"];

[self doIt];

return(YES);
}

- (void)doIt
{
if ([NSThread isMainThread] == NO)
	{
	[self performSelectorOnMainThread:@selector(doIt:) withObject:NULL waitUntilDone:YES];
	return;
	}
	
[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"CoreLogging_LastMailLogsAlertWhen"];
[[NSUserDefaults standardUserDefaults] synchronize];

UIAlertView *theAlert = [[[UIAlertView alloc] initWithTitle:NULL message:@"Do you want to email a log file containing debugging information to the developer of this software?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", NULL] autorelease];
[theAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
NSManagedObjectContext *theManagedObjectContext = self.logging.coreDataManager.managedObjectContext;

if (buttonIndex == 1)
	{
	NSMutableArray *theSessionsArray = [NSMutableArray array];

	for (NSManagedObjectID *theSessionID in self.sessions)
		{
		NSError *theError = NULL;
		NSManagedObject *theSession = [theManagedObjectContext existingObjectWithID:theSessionID error:&theError];
		if (theSession == NULL || theError != NULL)
			{
			return;
			}
		
		NSMutableDictionary *theSessionDictionary = [NSMutableDictionary dictionary];
		[theSessionDictionary setObject:[[theSession valueForKey:@"created"] ISO8601MinimalString] forKey:@"created"];
		
		NSMutableArray *theMessagesArray = [NSMutableArray array];
		
		NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"session == %@", theSession];

		NSArray *theMessages = [theManagedObjectContext fetchObjectsOfEntityForName:@"LoggingMessage" predicate:thePredicate error:&theError];
		for (NSManagedObject *theMessage in theMessages)
			{
			NSMutableDictionary *theMessageDictionary = [NSMutableDictionary dictionary];
			if ([theMessage valueForKey:@"extraAttributes"] != NULL)
				[theMessageDictionary setObject:[theMessage valueForKey:@"extraAttributes"] forKey:@"extraAttributes"];
			if ([theMessage valueForKey:@"facility"] != NULL)
				[theMessageDictionary setObject:[theMessage valueForKey:@"facility"] forKey:@"facility"];
			if ([theMessage valueForKey:@"level"] != NULL)
				[theMessageDictionary setObject:[theMessage valueForKey:@"level"] forKey:@"level"];
			if ([theMessage valueForKey:@"message"] != NULL)
				[theMessageDictionary setObject:[theMessage valueForKey:@"message"] forKey:@"message"];
			if ([theMessage valueForKey:@"sender"] != NULL)
				[theMessageDictionary setObject:[theMessage valueForKey:@"sender"] forKey:@"sender"];
			if ([theMessage valueForKey:@"timestamp"] != NULL)
				[theMessageDictionary setObject:[[theMessage valueForKey:@"timestamp"] ISO8601MinimalString] forKey:@"timestamp"];
			
			[theMessagesArray addObject:theMessageDictionary];
			}

		[theSessionDictionary setObject:theMessagesArray forKey:@"messages"];

		[theSessionsArray addObject:theSessionDictionary];
		}
		
	NSData *theJSON = [[CJSONDataSerializer serializer] serializeObject:theSessionsArray error:NULL];

	MFMailComposeViewController *theController = [[[MFMailComposeViewController alloc] init] autorelease];
	theController.mailComposeDelegate = self;
	[theController setToRecipients:self.recipients];
	[theController setSubject:self.subject];
	[theController setMessageBody:self.body isHTML:NO];
	[theController addAttachmentData:theJSON mimeType:@"application/json" fileName:@"Log.json"];

	[self.viewController presentModalViewController:theController animated:YES];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
if (result == MFMailComposeResultSaved || result == MFMailComposeResultSent)
	{
	NSManagedObjectContext *theManagedObjectContext = self.logging.coreDataManager.managedObjectContext;

	for (NSManagedObjectID *theSessionID in self.sessions)
		{
		NSError *theError = NULL;
		NSManagedObject *theSession = [theManagedObjectContext existingObjectWithID:theSessionID error:&theError];
		if (theSession == NULL || theError != NULL)
			{
			return;
			}
		[self.logging.coreDataManager.managedObjectContext deleteObject:theSession];
		}
	[self.logging.coreDataManager save];
	}

self.logging = NULL;
self.sessions = NULL;

[self.viewController dismissModalViewControllerAnimated:YES];
}

@end
