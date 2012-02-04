//  RXFutureTests.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXFuture.h"
#import "RXSynchronously.h"

@interface RXFutureTests : SenTestCase

@property (nonatomic, strong) RXFuture *future;
@property (nonatomic, strong) NSMutableSet *actions;

@end


@implementation RXFutureTests {
	dispatch_queue_t queue;
}

@synthesize future, actions;


-(void)setUp {
	self.future = [RXFuture new];
	self.actions = [NSMutableSet new];
	queue = dispatch_queue_create("RXFutureTests", 0);
}

-(void)tearDown {
	self.future = nil;
	self.actions = nil;
	dispatch_release(queue);
}


-(void)testCallsCancellationHandlersAfterCancelling {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:^{
			RXAssert(future.isCancelled);
			done();
		}];
		[future cancel];
	});
}

-(void)testCallsCompletionHandlersAfterCompleting {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:^{
			RXAssert(future.isCompleted);
			done();
		}];
		[future complete];
	});
}

-(void)testCancellationPrecludesCompletion {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future onCancel:done];
		[future cancel];
		[future complete];
	});
	
	RXAssert(future.isCancelled);
	RXAssertFalse(future.isCompleted);
}

-(void)testCompletionPrecludesCancellation {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future onCancel:done];
		[future complete];
		[future cancel];
	});
	
	RXAssertFalse(future.isCancelled);
	RXAssert(future.isCompleted);
}


-(void)addAction:(NSString *)action {
	dispatch_sync(queue, ^{
		[actions addObject:action];
	});
}


-(void)testCallsCancellationHandlersOnCancellation {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:^{
			[self addAction:@"a"];
			done();
		}];
		[future cancel];
	});
	RXAssertEquals(actions, [NSSet setWithObject:@"a"]);
}

-(void)testCallsCancellationHandlersAddedAfterCancellation {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future cancel];
		[future onCancel:^{
			[self addAction:@"a"];
			done();
		}];
	});
	RXAssertEquals(actions, [NSSet setWithObject:@"a"]);
}

-(void)testDoesNotCallCancellationHandlersOnCompletion {
	[future onCancel:^{ [self addAction:@"a"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future complete];
	});
	RXAssertEquals(actions, [NSSet set]);
}


-(void)testCallsCompletionHandlersOnCompletion {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:^{
			[self addAction:@"a"];
			done();
		}];
		[future complete];
	});
	RXAssertEquals(actions, [NSSet setWithObject:@"a"]);
}

-(void)testCallsCompletionHandlersAddedAfterCompletion {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future complete];
		[future onComplete:^{
			[self addAction:@"a"];
			done();
		}];
	});
	RXAssertEquals(actions, [NSSet setWithObject:@"a"]);
}

-(void)testDoesNotCallCompletionHandlersOnCancellation {
	[future onComplete:^{ [self addAction:@"a"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:done];
		[future cancel];
	});
	RXAssertEquals(actions, [NSSet set]);
}

@end
