//  RXFutureTests.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXFuture.h"
#import "RXSynchronously.h"

@interface RXFutureTests : SenTestCase

@property (nonatomic, strong) RXFuture *future;
@property (nonatomic, assign) NSUInteger result;

@end


@implementation RXFutureTests {
	dispatch_queue_t queue;
}

@synthesize future, result;


-(void)setUp {
	self.future = [RXFuture new];
	result = 0;
	queue = dispatch_queue_create("RXFutureTests", 0);
}

-(void)tearDown {
	self.future = nil;
	dispatch_release(queue);
	queue = NULL;
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


-(void)setResult:(NSUInteger)_result {
	dispatch_sync(queue, ^{
		result = _result;
	});
}


-(void)testCallsCancellationHandlersOnCancellation {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:^{
			self.result = 1;
			done();
		}];
		[future cancel];
	});
	RXAssertEquals(result, 1);
}

-(void)testCallsCancellationHandlersAddedAfterCancellation {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future cancel];
		[future onCancel:^{
			self.result = 2;
			done();
		}];
	});
	RXAssertEquals(result, 2);
}

-(void)testDoesNotCallCancellationHandlersOnCompletion {
	[future onCancel:^{ self.result = 3; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:done];
		[future complete];
	});
	RXAssertEquals(result, 0);
}


-(void)testCallsCompletionHandlersOnCompletion {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onComplete:^{
			self.result = 5;
			done();
		}];
		[future complete];
	});
	RXAssertEquals(result, 5);
}

-(void)testCallsCompletionHandlersAddedAfterCompletion {
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future complete];
		[future onComplete:^{
			self.result = 6;
			done();
		}];
	});
	RXAssertEquals(result, 6);
}

-(void)testDoesNotCallCompletionHandlersOnCancellation {
	[future onComplete:^{ self.result = 7; }];
	RXSynchronously(^(RXSynchronousCompletionBlock done) {
		[future onCancel:done];
		[future cancel];
	});
	RXAssertEquals(result, 0);
}

@end
