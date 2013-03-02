//
//  BBA_AppController.m
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import "BBA_AppController.h"
#import "BBA_PreferenceController.h"
#import "BBA_DefaultsController.h"

@implementation BBA_AppController

+ (void)initialize {
    
    // Register user defaults.
    [BBA_DefaultsController registerDefaults];
}
- (void)setup_statusBar {
    statusIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForImageResource:@"StatusIcon"]];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setToolTip:@"Silencer"];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:statusIcon];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
}

- (void)awakeFromNib {
    
    // Setup code for the status bar.
    [self setup_statusBar];
    
    // Listens for changes made in the preferences and calls a method to deal with those changes.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateScheduler)
                                                 name:@"dateObjectHasChanged"
                                               object:nil];
    
    [self updateScheduler];
    
}

// Show the preferences UI.
- (IBAction)showPreferences:(id)sender {
    
    if (!preferenceController) {
        preferenceController = [[BBA_PreferenceController alloc] init];
    }
    
    // If the UI is currently shown, then hide it before displaying it again.
    // This solves a problem where the UI is currently displayed on a different virtual desktop
    // and remains there instead of showing up on the current desktop.
    if([[preferenceController window] isVisible]) {
        [[preferenceController window] orderOut:self];
    }
    
    // Show the UI.
    [preferenceController showWindow:self];
}

#pragma mark mute code

- (void)muteDefaultAudioDevice {
    SetMute(GetDefaultAudioDevice(), YES);
}

- (void)unmuteDefaultAudioDevice {
    SetMute(GetDefaultAudioDevice(), NO);
}

AudioDeviceID GetDefaultAudioDevice()
{
    OSStatus err;
    AudioDeviceID device = 0;
    UInt32 size = sizeof(AudioDeviceID);
    AudioObjectPropertyAddress address = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    err = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                     &address,
                                     0,
                                     NULL,
                                     &size,
                                     &device);
    if (err)
    {
        NSLog(@"could not get default audio output device");
    }
    
    return device;
}

void SetMute(AudioDeviceID device, BOOL mute)
{
    UInt32 muteVal = (UInt32)mute;
    
    AudioObjectPropertyAddress address = {
        kAudioDevicePropertyMute,
        kAudioDevicePropertyScopeOutput,
        0
    };
    
    OSStatus err;
    err = AudioObjectSetPropertyData(device,
                                     &address,
                                     0,
                                     NULL,
                                     sizeof(UInt32),
                                     &muteVal);
    if (err)
    {
        NSString * message;
        /* big switch statement on err to set message */
        NSLog(@"error while %@muting: %@", (mute ? @"" : @"un"), message);
    }
}

#pragma mark Mute Functions

- (void)mute {
    NSLog(@"Muted at %@\n", [NSDate date]);
    /*
    SetMute(GetDefaultAudioDevice(), TRUE);
    sleep(1); // sleep 2 seconds to prevent the selector from fiering multiple times within the same second
    [self updateScheduler]; 
     
    this code can be removed safely
     */
}

- (void)unmute {
    NSLog(@"Unmuted at %@\n", [NSDate date]);
    /* 
    SetMute(GetDefaultAudioDevice(), FALSE);
    sleep(1); // sleep 2 seconds to prevent the selector from fiering multiple times within the same second
    [self updateScheduler];
     
     this code can be safely removed
     */
}

- (void)updateScheduler {
    NSInteger totalOffsetInSecondsForMute = 0;
    NSInteger totalOffsetInSecondsForUnmute = 0;
    
    
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now];
    
    NSDate *begin = [BBA_DefaultsController preferenceBeginDate];
    NSDateComponents *beginComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:begin];
    
    NSDate *end = [BBA_DefaultsController preferenceEndDate];
    NSDateComponents *endComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:end];
    
    int beginInSeconds = (int)([beginComponents hour] * 60 * 60 + [beginComponents minute] * 60 + [beginComponents second]);
    int endInSeconds = (int)([endComponents hour] * 60 * 60 + [endComponents minute] * 60 + [endComponents second]);
    int nowInSeconds = (int)([nowComponents hour] * 60 * 60 + [nowComponents minute] * 60 + [nowComponents second]);
    
    // was previously doing calculations with 60*60*60 which was incorrect
    totalOffsetInSecondsForMute = (beginInSeconds - nowInSeconds) % (60 * 60 * 24);
    if (totalOffsetInSecondsForMute < 0) totalOffsetInSecondsForMute += (60 * 60 * 24); // objC does not prevent negative modulus.

    totalOffsetInSecondsForUnmute = (endInSeconds - nowInSeconds) % (60 * 60 * 24);
    if (totalOffsetInSecondsForUnmute < 0) totalOffsetInSecondsForUnmute += (60 * 60 * 24); // objC does not prevent negative modulus.
    
    // Cancel any previous perform requests before creating a new request.
    // Must be done so we dont have multiple requests waiting after changing the preferences.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(mute) withObject:self afterDelay:totalOffsetInSecondsForMute];
    [self performSelector:@selector(unmute) withObject:self afterDelay:totalOffsetInSecondsForUnmute];
    
}

@end
