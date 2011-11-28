//  RXSynchronouslyTests.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXSynchronously.h"

@interface RXSynchronouslyTests : SenTestCase
@end

@implementation RXSynchronouslyTests

-(void)testSynchronizesOnTheCompletionOfAsynchronousWork {
	NSMutableArray *completedActions = [NSMutableArray new];
	RXSynchronously(^(RXSynchronousCompletionBlock didComplete) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[completedActions addObject:@"async"];
			didComplete();
		});
	});
	[completedActions addObject:@"sync"];
	
	RXAssertEquals(completedActions, ([NSArray arrayWithObjects:@"async", @"sync", nil]));
}


-(void)testTimesOutAfterASpecifiedWait {
	// this test has a race condition:
	// completedActions is not being serialized, and theoretically RXSynchronouslyWithTimeout could take the full second that the async block sleeps to complete
	// unlikely, but worth noting
	NSMutableArray *completedActions = [NSMutableArray new];
	RXSynchronouslyWithTimeout(DISPATCH_TIME_NOW, ^(RXSynchronousCompletionBlock didComplete) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			sleep(1);
			[completedActions addObject:@"async"];
			didComplete();
		});
	});
	[completedActions addObject:@"sync"];
	
	RXAssertEquals(completedActions, [NSArray arrayWithObject:@"sync"]);
}

@end
