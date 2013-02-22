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
        
    }
    return self;
}
-(void)muteAllDevices{
    [self identifyAllAudioDevices];
    
}
-(void)unmuteAllDevices{
    [self identifyAllAudioDevices];
    
}

// Private methods
-(AudioObjectPropertyAddress)getPropertyAddress{
    AudioObjectPropertyAddress property = {kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeOutput,
        kAudioObjectPropertyElementMaster};
    return property;
}

-(OSStatus)getPropertyDataSize{
    dataSize = 0;
    OSStatus stat = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
    return stat;
}
-(OSStatus)getPropertyData{
    return AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, audioDevices);
}

-(UInt32)getDeviceCount{
    return dataSize / sizeof(AudioDeviceID);
}
-(void)identifyAllAudioDevices{
    
    // get the number of currently present audiodevices on the system
    propertyAddress = [self getPropertyAddress];
    status = [self getPropertyDataSize];
    
    // kAudioHardwareNoError is a constant for 0
    // status is 0 if we are unable to get the data nessesary for computing the number of devices
    // TODO: do error handling
    if(kAudioHardwareNoError != status)
    {
        NSLog(@"Unable to get number of audio devices. Error: %d",status);
        //currentAudioDevices = NULL;
    }
    
    
    deviceCount = [self getDeviceCount];
    
    // c-array malloced
    audioDevices = malloc(dataSize);
    
    status = [self getPropertyData];
    
    if(kAudioHardwareNoError != status)
    {
        NSLog(@"AudioObjectGetPropertyData failed when getting device IDs. Error: %d",status);
        free(audioDevices), audioDevices = NULL;
        //return NULL;
    }
    
    currentAudioDevices = [[NSMutableArray alloc] init];
    for(UInt32 i = 0; i < deviceCount; i++)
    {
        NSLog(@"device found: %d",audioDevices[i]);
        [currentAudioDevices addObject:[NSNumber numberWithInt:audioDevices[i]]];
    }
    free(audioDevices);
}
@end
