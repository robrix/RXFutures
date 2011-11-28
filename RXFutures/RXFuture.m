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
	dispatch_release(queue);
}


-(void)onComplete:(void(^)())block {
	dispatch_async(queue, ^{
		[completionHandlers addObject:block];
	});
}

-(void)onCancel:(void(^)())block {
	dispatch_async(queue, ^{
		[cancellationHandlers addObject:block];
	});
}


-(void)cancel {
	dispatch_async(queue, ^{
		if(!cancelled && !completed) {
			self.cancelled = YES;
			for(void (^block)() in cancellationHandlers) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
			}
		}
	});
}

-(void)complete {
	dispatch_async(queue, ^{
		if(!cancelled && !completed) {
			self.completed = YES;
			for(void (^block)() in completionHandlers) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
			}
		}
	});
}

@end
