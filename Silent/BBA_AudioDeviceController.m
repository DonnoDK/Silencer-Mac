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
        // define the propertyAddress to use
        propertyAddress.mSelector = kAudioHardwarePropertyDevices;
        propertyAddress.mScope = kAudioObjectPropertyScopeOutput;
        propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    }
    return self;
}
-(void)muteAllDevices{
    [self identifyAllAudioDevices];
    if(currentAudioDevices != nil){
        for(BBA_AudioDevice *device in currentAudioDevices){
            [device mute];
        }
    }
}
-(void)unmuteAllDevices{
    [self identifyAllAudioDevices];
    if(currentAudioDevices != nil){
        for(BBA_AudioDevice *device in currentAudioDevices){
            [device unmute];
        }
    }
}

// Private methods
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
        AudioDeviceID deviceId = audioDevices[i];
        BBA_AudioDevice *test = [[BBA_AudioDevice alloc]initWithDeviceId:deviceId];
        [currentAudioDevices addObject:test];
    }
    free(audioDevices);
}
@end
