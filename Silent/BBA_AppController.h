//
//  BBA_AppController.h
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import "BBA_AudioDeviceController.h" // To mute/unmute all devices.

@class BBA_PreferenceController;

@interface BBA_AppController : NSObject {
    NSImage *statusIcon;
    NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
    
    BBA_PreferenceController *preferenceController;
    BBA_AudioDeviceController *audioDevicecontroller;
}

- (IBAction)showPreferences:(id)sender;
- (IBAction)emailSupport:(id)sender;

- (void)updateScheduler;

@end
