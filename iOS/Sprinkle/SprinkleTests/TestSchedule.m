//
//  TestSchedule.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <XCTest/XCTest.h>
#import "Schedule.h"

@interface TestSchedule : XCTestCase

@end

@implementation TestSchedule

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testDaysOfWeekStringFromInt {
    ScheduleDays days;
    NSString *result;
    days = Monday | Tuesday | Wednesday | Thursday;
    result = [Schedule dayOfWeekStringFromInt:days];
    XCTAssert([result isEqualToString:@"mon,tue,wed,thu"]);
    
    days = Monday | Tuesday | Wednesday | Thursday | Sunday;
    result = [Schedule dayOfWeekStringFromInt:days];
    XCTAssert([result isEqualToString:@"mon,tue,wed,thu,sun"]);
}

-(void) testScheduleDaysFromString {
    NSString *days;
    ScheduleDays expect;
    
    days = @"mon,tue,wed,thu";
    expect = Monday | Tuesday | Wednesday | Thursday;
    XCTAssertEqual(expect, [Schedule scheduleDaysFromString:days]);
    
}

@end
