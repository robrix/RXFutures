// RXMockObject.m
// Created by Rob Rix on 2010-03-20
// Copyright 2010 Monochrome Industries

#import "RXMockObject.h"
#import <objc/runtime.h>

NSString * const RXMockNull = @"RXMockNull";

@implementation RXMockObject

-(id)init {
	if(self = [super init]) {
		responses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc {
	[responses release];
	[super dealloc];
}


+(RXMockObject *)mockObject {
	return [[[self alloc] init] autorelease];
}

+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector {
	RXMockObject *object = [[[self alloc] init] autorelease];
	[object setResponseObject: response forSelector: selector];
	return object;
}

+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector withArgument:(id)argument {
	RXMockObject *object = [[[self alloc] init] autorelease];
	[object setResponseObject: response forSelector: selector withArgument: argument];
	return object;
}

+(RXMockObject *)mockObjectWithResponseObject:(id)response forSelector:(SEL)selector withArguments:(NSArray *)arguments {
	RXMockObject *object = [[[self alloc] init] autorelease];
	[object setResponseObject: response forSelector: selector withArguments: arguments];
	return object;
}


-(void)setResponseObject:(id)response forSelector:(SEL)selector {
	[self setResponseObject: response forSelector: selector withArguments: [NSArray array]];
	
}

-(void)setResponseObject:(id)response forSelector:(SEL)selector withArgument:(id)argument {
	[self setResponseObject: response forSelector: selector withArguments: [NSArray arrayWithObject: argument ?: RXMockNull]];
}

-(void)setResponseObject:(id)response forSelector:(SEL)selector withArguments:(NSArray *)arguments {
	NSMutableDictionary *responsesByArguments = [responses objectForKey: NSStringFromSelector(selector)];
	if(!responsesByArguments) {
		[responses setObject: (responsesByArguments = [NSMutableDictionary dictionary]) forKey: NSStringFromSelector(selector)];
	}
	[responsesByArguments setObject: response ?: RXMockNull forKey: arguments];
}

-(id)responsesForSelector:(SEL)selector {
	return [responses objectForKey: NSStringFromSelector(selector)];
}

-(id)responseForSelector:(SEL)selector withArguments:(NSArray *)arguments {
	return [[self responsesForSelector: selector] objectForKey: arguments];
}


-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = nil;
	if([self responsesForSelector: selector]) {
		NSUInteger arity = ([NSStringFromSelector(selector) componentsSeparatedByString: @":"].count - 1u);
		NSMutableArray *argumentTypes = [NSMutableArray array];
		for(NSUInteger i = 0; i < arity; i++) {
			[argumentTypes addObject: [NSString stringWithUTF8String: @encode(id)]];
		}
		signature = [NSMethodSignature signatureWithObjCTypes: [[NSString stringWithFormat: @"%s%s%s%@", @encode(id), @encode(SEL), @encode(id), [argumentTypes componentsJoinedByString: @""]] UTF8String]];
	}
	return signature;
}

-(void)forwardInvocation:(NSInvocation *)invocation {
	if([self responsesForSelector: invocation.selector]) {
		NSMutableArray *arguments = [NSMutableArray array];
		for(NSUInteger i = 2; i < invocation.methodSignature.numberOfArguments; i++) {
			id argument;
			[invocation getArgument: &argument atIndex: i];
			[arguments addObject: argument ?: RXMockNull];
		}
		id response = [self responseForSelector: invocation.selector withArguments: [arguments copy]];
		if(response == RXMockNull) response = nil;
		[invocation setReturnValue: &response];
	}
}

@end
