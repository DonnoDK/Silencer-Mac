//
//  BBA_AudioDevice.m
//  Silencer
//
//  Created by Brian Pedersen on 23/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_AudioDevice.h"

@implementation BBA_AudioDevice
-(id)init{
    assert(false && @"BBA_AudioDevice not allowed instantiation using -(id)init. Use -(id)initWithDeviceId:deviceId instead");
}
-(id)initWithDeviceId:(AudioDeviceID)newId{
    self = [super init];
    if (self) {
        assert(self && @"BBA_AudioDevice failed to instantiate");
        propertyAddres.mSelector = kAudioDevicePropertyMute;
        propertyAddres.mScope = kAudioDevicePropertyScopeOutput;
        propertyAddres.mElement = kAudioObjectPropertyElementMaster;
        device = newId;
    }
    return self;
}
-(BOOL)mute{
    [self muteDevice:YES];
    if(error)
        return NO;
    else
        return YES;
}
-(BOOL)unmute{
    [self muteDevice:NO];
    if(error)
        return NO;
    else
        return YES;
}

// private methods
-(void)muteDevice:(BOOL)shouldMute{
    UInt32 muteValue = (UInt32)shouldMute;
    bool canMuteAndUnmute = AudioObjectHasProperty(device, &propertyAddres);
    if(canMuteAndUnmute){
        error = AudioObjectSetPropertyData(device, &propertyAddres, 0, nil, sizeof(UInt32), &muteValue);
    }
}
@end