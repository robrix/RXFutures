//  RXSynchronously.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXSynchronously.h"

void RXSynchronously(RXSynchronousBlock block) {
	RXSynchronouslyWithTimeout(DISPATCH_TIME_FOREVER, block);
}

void RXSynchronouslyWithTimeout(dispatch_time_t timeout, RXSynchronousBlock block) {
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	block(^{
		dispatch_semaphore_signal(semaphore);
	});
	
	dispatch_semaphore_wait(semaphore, timeout);
	dispatch_release(semaphore);
}
