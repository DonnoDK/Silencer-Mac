//
//  BBA_Logger_tests.m
//  Silencer
//
//  Created by Brian Pedersen on 02/03/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_Logger_tests.h"


@implementation BBA_Logger_tests
- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testLoggerDoesLog{
    BBALog(@"This is a test",BBA_ALERT, self);
    BBALog(@"Could not get enough beer!", BBA_CRITICAL, self);
}


@end
