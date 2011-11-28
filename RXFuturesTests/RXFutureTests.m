//  RXFutureTests.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXFuture.h"
#import "RXSynchronously.h"

@interface RXFutureTests : SenTestCase
@end


@implementation RXFutureTests

-(void)testCanBeCancelled {
	RXFuture *future = [RXFuture new];
	
	RXSynchronously(^(RXSynchronousCompletionBlock didCancel) {
		[future cancelWithCompletionHandler:^{
			didCancel();
		}];
	});
	
	RXAssert(future.isCancelled);
}

@end
