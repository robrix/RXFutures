//  RXFuture.m
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXFuture.h"

@interface RXFuture ()

@property (nonatomic, readwrite, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, assign, getter=isCompleted) BOOL completed;

@end

@implementation RXFuture

@synthesize cancelled, completed;

-(id)init {
	if((self = [super init])) {
		completionHandlers = [NSMutableSet new];
		cancellationHandlers = [NSMutableSet new];
		queue = dispatch_queue_create("com.monochromeindustries.RXFuture", 0);
	}
	return self;
}

-(void)dealloc {
	[completionHandlers release];
	[cancellationHandlers release];
	dispatch_release(queue);
	[super dealloc];
}


-(void)dispatchCallback:(void(^)())block {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


-(void)onCancel:(void(^)())block {
	[self performBlock:^{
		if(cancelled)
			[self dispatchCallback:block];
		else
			[cancellationHandlers addObject:block];
	}];
}

-(void)cancel {
	[self performBlock:^{
		if(!cancelled && !completed) {
			self.cancelled = YES;
			for(void (^block)() in cancellationHandlers) {
				[self dispatchCallback:block];
			}
		}
	}];
}

-(void)cancel:(void(^)())block {
	[self onCancel:block];
	[self cancel];
}


-(void)onComplete:(void(^)())block {
	[self performBlock:^{
		if(completed)
			[self dispatchCallback:block];
		else
			[completionHandlers addObject:block];
	}];
}

-(void)complete {
	[self performBlock:^{
		if(!cancelled && !completed) {
			self.completed = YES;
			for(void (^block)() in completionHandlers) {
				[self dispatchCallback:block];
			}
		}
	}];
}

-(void)complete:(void(^)())block {
	[self onComplete:block];
	[self complete];
}


-(void)performBlock:(void(^)())block {
	dispatch_async(queue, block);
}


-(void)unlessCancelled:(void(^)())block {
	[self performBlock:^{
		if(!cancelled) block();
	}];
}


-(void)cascadeCancellationToFuture:(RXFuture *)future {
	[self onCancel:^{ [future cancel]; }];
}

@end
