//
//  BBA_AudioDevice.h
//  Silencer
//
//  Created by Brian Pedersen on 23/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

@interface BBA_AudioDevice : NSObject{
    AudioDeviceID device;
    AudioObjectPropertyAddress propertyAddres;
    OSStatus error;
    NSString *deviceName;
    NSString *deviceManufacturer;
}
-(id)initWithDeviceId:(AudioDeviceID)newId andName:(NSString*)name andManufacturer:(NSString*)manufacturer;
-(void)mute;
-(void)unmute;
@end
