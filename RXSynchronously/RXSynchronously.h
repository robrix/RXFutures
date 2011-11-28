//  RXSynchronously.h
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import <Foundation/Foundation.h>

typedef void (^RXSynchronousCompletionBlock)();
typedef void (^RXSynchronousBlock)(RXSynchronousCompletionBlock);

/*
Synchronizes the calling thread with the asynchronous work you do in the block you pass to it.

Like so:

	RXSynchronously(^(RXSynchronousCompletionBlock didComplete) {
		[worker doSomeAsynchronousWorkWithCompletionHandler:^{
			// clean up, notify, etc
			didComplete(); // call the didComplete block you received to conclude waiting
		}];
	});
	// continue on, safe in the knowledge that the asynchronous work has completed

RXSynchronously will block until didComplete() is called.

Its impatient sibling, RXSynchronouslyWithTimeout, lets you time out on the wait. Using DISPATCH_TIME_NOW as the timeout is a quick and easy way to test if the work you’re doing is actually performed synchronously or asynchronously (but beware a race condition—fast asynchronous work could complete before RXSynchronouslyWithTimeout returns).
*/

void RXSynchronously(RXSynchronousBlock block); // never times out
void RXSynchronouslyWithTimeout(dispatch_time_t timeout, RXSynchronousBlock block);
