//
//  audioDevicesTests.m
//  audioDevicesTests
//
//  Created by Brian Pedersen on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "audioDeviceTests.h"

@implementation audioDeviceTests

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

- (void)testAudioDeviceInstantiationSucceeds
{
    BBA_AudioDeviceController *contr = [[BBA_AudioDeviceController alloc] init];
    [contr muteAllDevices];
    [contr unmuteAllDevices];
    STAssertNotNil(contr, @"Could not properly instantiate a BBA_AudioDevice");
}

@end
