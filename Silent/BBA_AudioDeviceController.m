//
//  BBA_AudioDeviceController.m
//  Silencer
//
//  Created by Brian Pedersen on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_AudioDeviceController.h"
#import "BBA_Logger.h"

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
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    propertyAddress.mScope = kAudioObjectPropertyScopeOutput;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
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
    // Bail out
    if(error){
        //NSLog(@"Unable to get number of audio devices. Error: %d",error);
        NSString *logstring = [NSString stringWithFormat:@"Unable to get number of audio devices. Error: %d",error];
        BBALog(logstring, BBA_ERROR, self);
        currentAudioDevices = nil;
        return;
    }
    
    [self calculateDeviceCount];
    
    // c-array malloced. HAS to be a c-array as AudioObjectGetPropertyData requires it.
    audioDevices = malloc(dataSize);
    
    // get data for the currently identified audio devices within the system
    [self queryPropertyData];
    
    // status is != 0 if we are unable to get any data
    // associated with the audio devices we previously identified.
    // Free up resources and bail
    if(error)
    {
        NSString *logstring = [NSString stringWithFormat:@"AudioObjectGetPropertyData failed when getting device IDs. Error: %d",error];
        BBALog(logstring, BBA_ERROR, self);
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
        NSString *deviceName = [self determineDeviceNameForDevice:deviceId];
        NSString *deviceManufacturer = [self determineManufacturerNameForDevice:deviceId];
        BBA_AudioDevice *test = [[BBA_AudioDevice alloc]initWithDeviceId:deviceId andName:deviceName andManufacturer:deviceManufacturer];
        [currentAudioDevices addObject:test];
    }
    free(audioDevices);
}
-(NSString*)determineDeviceNameForDevice:(AudioDeviceID)deviceId{
    char deviceName[64];
    dataSize = sizeof(deviceName);
    propertyAddress.mSelector = kAudioDevicePropertyDeviceName;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, NULL, &dataSize, deviceName);
    return [NSString stringWithUTF8String:deviceName];
}
-(NSString*)determineManufacturerNameForDevice:(AudioDeviceID)deviceId{
    char manufacturerName[64];
    dataSize = sizeof(manufacturerName);
    propertyAddress.mSelector = kAudioDevicePropertyDeviceManufacturer;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, NULL, &dataSize, manufacturerName);
    return [NSString stringWithUTF8String:manufacturerName];
}
-(NSString*)determineUIDStringForDevice:(AudioDeviceID)deviceId{
    // We dont use this method for now, but if we later want to use it, then its here
    // Gets the unique UID string for a device.
    CFStringRef uidString;
    
    dataSize = sizeof(uidString);
    propertyAddress.mSelector = kAudioDevicePropertyDeviceUID;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, NULL, &dataSize, &uidString);
    //NSLog(@"device %s by %s id %@", deviceName, manufacturerName, uidString);
    NSString *uidNSString = [NSString stringWithString:CFBridgingRelease(uidString)];
    CFRelease(uidString);
    return uidNSString;
}
@end
