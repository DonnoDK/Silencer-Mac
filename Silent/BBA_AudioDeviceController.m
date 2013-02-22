//
//  BBA_AudioDeviceController.m
//  Silencer
//
//  Created by Brian Pedersen on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_AudioDeviceController.h"

@implementation BBA_AudioDeviceController

-(id)init{
    self = [super init];
    if (self) {
        // setting instance variables to sane default values
        error = 0;
        currentAudioDevices = nil;
        audioDevices = nil;
        dataSize = 0;
        deviceCount = 0;
    }
    return self;
}
-(void)muteAllDevices{
    [self identifyAllAudioDevices];
    if(currentAudioDevices != nil){
        for(NSNumber *device in currentAudioDevices){
            AudioDeviceID deviceId = (UInt32)[device integerValue];
            [self muteAudioDevice:deviceId shouldMute:YES];
        }
    }
}
-(void)unmuteAllDevices{
    [self identifyAllAudioDevices];
    if(currentAudioDevices != nil){
        for(NSNumber *device in currentAudioDevices){
            AudioDeviceID deviceId = (UInt32)[device integerValue];
            [self muteAudioDevice:deviceId shouldMute:NO];
        }
    }
}

// Private methods
-(void)muteAudioDevice:(AudioDeviceID)device shouldMute:(bool)mute{
    UInt32 muteVal = (UInt32)mute;
    
    propertyAddress.mSelector = kAudioDevicePropertyMute;
    propertyAddress.mScope = kAudioDevicePropertyScopeOutput;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;

    // can this device mute/unmute?
    bool canMuteAndUnmute = AudioObjectHasProperty(device, &propertyAddress);
    
    error = 0;
    if(canMuteAndUnmute){
        error = AudioObjectSetPropertyData(
                                    device,
                                     &propertyAddress,
                                     0,
                                     nil,
                                     sizeof(UInt32),
                                     &muteVal);
        NSLog(@"Device %u is now %@muted",device, (mute ? @"" : @"un"));
    }
    if (error)
    {
        /* big switch statement on err to set message */
        NSLog(@"error while %@muting: %u, error: %d", (mute ? @"" : @"un"), device, error);
    }
}
-(void)queryPropertyAddress{
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    propertyAddress.mScope = kAudioObjectPropertyScopeOutput;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
}
-(void)queryPropertyDataSize{
    error = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
}
-(void)queryPropertyData{
    error = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, audioDevices);
}
-(void)calculateDeviceCount{
    deviceCount = dataSize / sizeof(AudioDeviceID);
}
-(void)identifyAllAudioDevices{
    
    // get the number of currently present audiodevices on the system
    [self queryPropertyAddress];
    [self queryPropertyDataSize];
    
    // status is != 0 if we are unable to get the data nessesary for computing the number of devices
    if(error){
        NSLog(@"Unable to get number of audio devices. Error: %d",error);
        currentAudioDevices = nil;
        return;
    }
    
    [self calculateDeviceCount];
    
    // c-array malloced
    audioDevices = malloc(dataSize);
    
    // get data for the currently identified audio devices within the system
    [self queryPropertyData];
    
    // status is != 0 if we are unable to get any data
    // associated with the audio devices we previously identified
    if(error)
    {
        NSLog(@"AudioObjectGetPropertyData failed when getting device IDs. Error: %d",error);
        free(audioDevices);
        audioDevices = NULL;
        currentAudioDevices = NULL;
        return;
    }
    
    // if all went well, iterate through all devices and add them to our currentAudioDevices
    currentAudioDevices = [[NSMutableArray alloc] init];
    for(UInt32 i = 0; i < deviceCount; i++)
    {
        //NSLog(@"device found: %d",audioDevices[i]);
        [currentAudioDevices addObject:[NSNumber numberWithInt:audioDevices[i]]];
    }
    free(audioDevices);
}
@end
