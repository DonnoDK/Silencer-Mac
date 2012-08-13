//
//  BBA_AppController.h
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
@class BBA_PreferenceController;

@interface BBA_AppController : NSObject {
    NSImage *statusIcon;
    NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
    
    BBA_PreferenceController *preferenceController;
}

- (IBAction)showPreferences:(id)sender;

- (void)muteDefaultAudioDevice;
- (void)unmuteDefaultAudioDevice;

AudioDeviceID GetDefaultAudioDevice();
void SetMute(AudioDeviceID device, BOOL mute);

- (void)updateScheduler;

@end
