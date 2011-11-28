// RXMockObjectTests.m
// Created by Rob Rix on 2010-03-22
// Copyright 2010 Monochrome Industries

#import "RXAssertions.h"
#import "RXMockObject.h"

@interface NSObject (RXMockObjectTests)
-(id)nullary;
-(id)unary:(id)arg;
-(id)binary:(id)arg1 method:(id)arg2;
@end

@interface RXMockObjectTests : SenTestCase {
	id mock;
}
@end

@implementation RXMockObjectTests

-(void)setUp {
	mock = [RXMockObject mockObject];
}

-(void)testRespondsToNullaryMessagesWithTheGivenObject {
	[mock setResponseObject: @"nullary response" forSelector: @selector(nullary)];
	RXAssertEquals([mock nullary], @"nullary response");
}

-(void)testRespondsToUnaryMessagesWithTheGivenObject {
	[mock setResponseObject: @"result 1" forSelector: @selector(unary:) withArgument: @"argument 1"];
	[mock setResponseObject: @"result 2" forSelector: @selector(unary:) withArgument: @"argument 2"];
	RXAssertEquals([mock unary: @"argument 1"], @"result 1");
	RXAssertEquals([mock unary: @"argument 2"], @"result 2");
	RXAssertNil([mock unary: @"not specified"]);
	RXAssertNil([mock unary: nil]);
}

-(void)testRespondsToMessagesWithNilArguments {
	[mock setResponseObject: @"result 1" forSelector: @selector(unary:) withArgument: nil];
	[mock setResponseObject: @"result 2" forSelector: @selector(unary:) withArgument: @"argument 2"];
	RXAssertEquals([mock unary: nil], @"result 1");
	RXAssertEquals([mock unary: @"argument 2"], @"result 2");
	RXAssertNil([mock unary: @"not specified"]);
}


-(void)testAcceptsNilResponses {
	[mock setResponseObject: nil forSelector: @selector(nullary)];
	[mock setResponseObject: nil forSelector: @selector(unary:) withArgument: nil];
	[mock setResponseObject: @"" forSelector: @selector(unary:) withArgument: @""];
	[mock setResponseObject: nil forSelector: @selector(binary:method:) withArguments: [NSArray arrayWithObjects: RXMockNull, RXMockNull, nil]];
	[mock setResponseObject: @"" forSelector: @selector(binary:method:) withArguments: [NSArray arrayWithObjects: @"", RXMockNull, nil]];
	[mock setResponseObject: @"" forSelector: @selector(binary:method:) withArguments: [NSArray arrayWithObjects: RXMockNull, @"", nil]];
	RXAssertNil([mock nullary]);
	RXAssertNil([mock unary: nil]);
	RXAssertNotNil([mock unary: @""]);
	RXAssertNil([mock binary: nil method: nil]);
	RXAssertNotNil([mock binary: @"" method: nil]);
	RXAssertNotNil([mock binary: nil method: @""]);
}

@end
