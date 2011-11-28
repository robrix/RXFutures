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
	dispatch_async(queue, ^{
		[actions addObject:action];
	});
}


-(void)testCallsCancellationHandlersOnCancellation {
	[future onCancel:^{ [self addAction:@"a"]; }];
	[future onCancel:^{ [self addAction:@"b"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:done];
		[future cancel];
	});
	RXAssertEquals(actions, ([NSSet setWithObjects:@"a", @"b", nil]));
}

-(void)testDoesNotCallCancellationHandlersOnCompletion {
	[future onCancel:^{ [self addAction:@"a"]; }];
	[future onCancel:^{ [self addAction:@"b"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future complete];
	});
	RXAssertEquals(actions, [NSSet set]);
}


-(void)testCallsCompletionHandlersOnCompletion {
	[future onComplete:^{ [self addAction:@"a"]; }];
	[future onComplete:^{ [self addAction:@"b"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future complete];
	});
	RXAssertEquals(actions, ([NSSet setWithObjects:@"a", @"b", nil]));
}

-(void)testDoesNotCallCompletionHandlersOnCancellation {
	[future onComplete:^{ [self addAction:@"a"]; }];
	[future onComplete:^{ [self addAction:@"b"]; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:done];
		[future cancel];
	});
	RXAssertEquals(actions, [NSSet set]);
}

@end
