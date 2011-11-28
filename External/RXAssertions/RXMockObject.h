// RXMockObject.h
// Created by Rob Rix on 2010-03-20
// Copyright 2010 Monochrome Industries

#import <Foundation/Foundation.h>

// use RXMockNull to represent a nil return or a nil value in an argument list.
// this is used instead of +[NSNull null] to let us use +[NSNull null] in our tests themselves.
extern NSString * const RXMockNull;

@interface RXMockObject : NSObject {
	NSMutableDictionary *responses;
}

+(RXMockObject *)mockObject;
+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector;
+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector withArgument:(id)argument;
+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector withArguments:(NSArray *)arguments;

-(void)setResponseObject:(id)object forSelector:(SEL)selector;
-(void)setResponseObject:(id)object forSelector:(SEL)selector withArgument:(id)argument;
-(void)setResponseObject:(id)response forSelector:(SEL)selector withArguments:(NSArray *)arguments;

@end
