# TouchLogging

Source code for providing simple logging to CoreData functionality.

## License

This code is licensed under the 2-clause BSD license ("Simplified BSD License" or "FreeBSD License") license. The license is reproduced below:

Copyright 2011 Jonathan Wight. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Jonathan Wight.

## Automatic Reference Counting (ARC)

The source code in this repository uses Automatic Reference Counting. Older, non-ARC source code may exist in a "feature/nonARC" maintenance branch.

## Requirements

You need "CCoreDataManager.h/.m" from "{TouchCode}/Support/Common/CoreData".

## Description

Log messages comprise of a sender string, facility string, level integer, timestamp, a message string and a dictionary of extra attributes.

By default all log messages are printed to stderr and saved to core data.

## Usage

All symbols with a trailing underscore are preprocessor macros and not functions.

You can turn the logging macros on and off with the LOGGING preprocessor define. If set to 1 this define will cause all the macros to do nothing. The CLogging class will still exist and can be access via its methods and properties like any other class.

At the very basic level you just need to call a logging macro:

    LogDebug_(@"This is a logging message!");

That is equivalent (and preferable) to:

	Log_(LoggingLevel_DEBUG, @"This is a logging message!");

Convenience categories exist for logging NSError and NSException objects:

	NSError *theError = [someObject someMethodReturningAnError];
	[theError log];

You can set up the logging defaults before logging any messages:

	[CLogging instance].sender = @"Test Sender";
	[CLogging instance].facility = @"Test Facility";

## Multithreading

TouchLogging should be thread safe. Each thread should have its own CoreData NSManagedObjectContext (a function of CCoreDataManager).

## CLoggingHandler and events

CLogging defines the notion of events that occur during CLogging's lifetime. These events are named: "start", "log" and "end". These events occur when logging starts, when a log message is sent and at end of logging respectively.

You can register objects that conform to the CLoggingHandler protocol:

    [[CLogging instance] addHandler:theHandler forEvents:[NSArray arrayWithObject:@"start"];

When an event occurs CLogging will send the follow message

    - (BOOL)handleLogging:(CLogging *)inLogging event:(NSString *)inEvent error:(NSError **)outError;

A sample handler (in the Extras directory) shows how to email the logging data on the iPhone.

## Performance

TouchLogging is not intended to be a high performance logging framework. You should not be logging hundreds of messages per second.

## BUGS

"end" event does not fire because CLogging is a leaking singleton.

## TODO

Improve performance by either deferring CoreData saves until needed or offload message saving into background operations.
