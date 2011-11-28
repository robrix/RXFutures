// RXAssertionHelperTests.m
// Created by Rob Rix on 2010-04-09
// Copyright 2010 Monochrome Industries

#import "RXAssertions.h"

@interface RXAssertionHelperTests : SenTestCase
@end

@implementation RXAssertionHelperTests

-(void)testCanTestRangesForEquality {
	NSRange a = NSMakeRange(0, 1), b = NSMakeRange(0, 1), c = NSMakeRange(1, 2);
	RXAssert([RXAssertionHelper compareValue: &a withValue: &b ofObjCType: @encode(NSRange)]);
	RXAssertFalse([RXAssertionHelper compareValue: &a withValue: &c ofObjCType: @encode(NSRange)]);
	
	// RXAssertEquals(NSMakeRange(0, 1), NSMakeRange(0, 1));
	// RXAssertNotEquals(NSMakeRange(0, 1), NSMakeRange(1, 2));
}

-(void)testCanTestCoreFoundationStringsForEquality {
	RXAssertEquals(CFSTR("foo"), (CFStringRef)@"foo");
}

@end