//
//  BBA_AudioDevice.m
//  Silencer
//
//  Created by Brian Pedersen on 23/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_AudioDevice.h"
#import "BBA_Logger.h"

@implementation BBA_AudioDevice
-(id)init{
    assert(false && @"BBA_AudioDevice not allowed instantiation using -(id)init. Use -(id)initWithDeviceId:deviceId... instead");
}
-(id)initWithDeviceId:(AudioDeviceID)newId andName:(NSString *)name andManufacturer:(NSString *)manufacturer{
    self = [super init];
    if (self) {
        propertyAddres.mSelector = kAudioDevicePropertyMute;
        propertyAddres.mScope = kAudioDevicePropertyScopeOutput;
        propertyAddres.mElement = kAudioObjectPropertyElementMaster;
        device = newId;
        deviceName = name;
        deviceManufacturer = manufacturer;
    }else{
        assert(self && @"BBA_AudioDevice failed to instantiate");
    }
    return self;
}
-(void)mute{
    [self muteDevice:YES];
    if(error){
        NSString *logstring = [NSString stringWithFormat:@"Failed to mute deviceId: %u, deviceName: %@, manufacturer: %@, with error: %d", device,deviceName,deviceManufacturer,error];
        BBALog(logstring, BBA_ERROR, self);
    }else{
        NSString *logstring = [NSString stringWithFormat:@"Muted device:%u, named:%@ successfully",device,deviceName];
        BBALog(logstring, BBA_INFO, self);
    }
}
-(void)unmute{
    [self muteDevice:NO];
    if(error){
        NSString *logstring = [NSString stringWithFormat:@"Failed to unmute deviceId: %u, deviceName: %@, manufacturer: %@, with error: %d", device,deviceName,deviceManufacturer,error];
        BBALog(logstring, BBA_ERROR, self);
    }else{
        NSString *logstring = [NSString stringWithFormat:@"Unmuted device:%u, named:%@ successfully",device,deviceName];
        BBALog(logstring, BBA_INFO, self);
    }
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