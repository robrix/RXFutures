//  RXFuture.h
//  Created by Rob Rix on 11-11-27.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXFuture : NSObject {
@private
	BOOL completed;
	BOOL cancelled;
	NSMutableSet *completionHandlers;
	NSMutableSet *cancellationHandlers;
	dispatch_queue_t queue;
}

-(void)onComplete:(void(^)())block;
-(void)onCancel:(void(^)())block;

-(void)cancel;
-(void)complete;

@property (nonatomic, readonly, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, assign, getter=isCompleted) BOOL completed;

@end
