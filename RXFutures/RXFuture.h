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
-(void)complete;
-(void)complete:(void(^)())block; // shorthand for -onComplete: followed by -complete

-(void)onCancel:(void(^)())block;
-(void)cancel;
-(void)cancel:(void(^)())block; // shorthand for -onCancel: followed by -cancel

-(void)performBlock:(void(^)())block;

-(void)unlessCancelled:(void(^)())block;

// these properties are only meaningful and safe within blocks passed to -performBlock:
@property (nonatomic, readonly, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, assign, getter=isCompleted) BOOL completed;

-(void)cascadeCancellationToFuture:(RXFuture *)future; // cancels the argument when the receiver is cancelled

@end
