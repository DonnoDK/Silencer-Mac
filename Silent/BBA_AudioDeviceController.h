//
//  BBA_AudioDeviceController.h
//  Silencer
//
//  Created by Brian Pedersen on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "BBA_AudioDevice.h"

@interface BBA_AudioDeviceController : NSObject{
    NSMutableArray *currentAudioDevices;
    AudioDeviceID *audioDevices;
    AudioObjectPropertyAddress propertyAddress;
    OSStatus error;
    UInt32 dataSize;
    UInt32 deviceCount;
}
-(id)init;
-(void)muteAllDevices;
-(void)unmuteAllDevices;

@end
