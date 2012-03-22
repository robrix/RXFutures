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


+(RXFuture *)future {
#if !__has_feature(objc_arc)
	return [[self new] autorelease];
#else
	return [self new];
#endif
}


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
#if !__has_feature(objc_arc)
	[completionHandlers release];
	[cancellationHandlers release];
	[super dealloc];
#endif
}


-(void)dispatchCallback:(void(^)())block {
	dispatch_async(queue, block);
}


-(void)onCancel:(void(^)())block {
	if(block)
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
#if !__has_feature(objc_arc)
			[completionHandlers release];
			[cancellationHandlers release];
#endif
			completionHandlers = nil;
			cancellationHandlers = nil;
		}
	}];
}

-(void)cancel:(void(^)())block {
	[self onCancel:block];
	[self cancel];
}


-(void)onComplete:(void(^)())block {
	if(block)
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
#if !__has_feature(objc_arc)
			[completionHandlers release];
			[cancellationHandlers release];
#endif
			completionHandlers = nil;
			cancellationHandlers = nil;
		}
	}];
}

-(void)complete:(void(^)())block {
	[self onComplete:block];
	[self complete];
}


-(void)onCleanUp:(void(^)())block {
	[self onComplete:block];
	[self onCancel:block];
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
	if(future)
		[self onCancel:^{ [future cancel]; }];
}

-(void)passControlToFuture:(RXFuture *)future {
	if (future)
	{
		[self onCancel:^{ [future cancel]; }];
		[future onCancel:^{ [self cancel]; }];
		[future onComplete:^{ [self complete]; }];
	}
}

@end
