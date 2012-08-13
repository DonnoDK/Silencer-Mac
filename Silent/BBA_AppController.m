//
//  BBA_AppController.m
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import "BBA_AppController.h"
#import "BBA_PreferenceController.h"

@implementation BBA_AppController

// Register defaults
+ (void)initialize {
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"autostart"];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startDateComponent = [[NSDateComponents alloc] init];
    [startDateComponent setYear:1983];   // random value
    [startDateComponent setMonth:1];     // random value
    [startDateComponent setDay:1];       // random value
    [startDateComponent setHour:22];
    [startDateComponent setMinute:0];
    [startDateComponent setSecond:00];
    
    NSDateComponents *endDateComponent = [[NSDateComponents alloc] init];
    [endDateComponent setYear:1983];    // random value
    [endDateComponent setMonth:1];      // random value
    [endDateComponent setDay:1];        // random value
    [endDateComponent setHour:8];
    [endDateComponent setMinute:0];
    [endDateComponent setSecond:0];
    
    NSDate *startDate = [gregorian dateFromComponents:startDateComponent];
    NSDate *endDate = [gregorian dateFromComponents:endDateComponent];
    
    [defaultValues setObject:startDate forKey:@"start"];
    [defaultValues setObject:endDate forKey:@"end"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}
- (void)awakeFromNib {
    statusIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForImageResource:@"StatusIcon"]];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setToolTip:@"Silent"];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:statusIcon];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(updateScheduler)
               name:@"updateScheduler"
             object:nil];
    [self updateScheduler];
    
    // set up muter ////
}

- (IBAction)showPreferences:(id)sender {
    if (!preferenceController) {
        preferenceController = [[BBA_PreferenceController alloc] init];
    }
    [preferenceController showWindow:self];
}


#pragma mark -

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
    SetMute(GetDefaultAudioDevice(), TRUE);
    sleep(1); // sleep 2 seconds to prevent the selector from fiering multiple times within the same second
    [self updateScheduler];
}

- (void)unmute {
    SetMute(GetDefaultAudioDevice(), FALSE);
    sleep(1); // sleep 2 seconds to prevent the selector from fiering multiple times within the same second
    [self updateScheduler];
}

- (void)updateScheduler {
    NSInteger totalOffsetInSecondsForMute = 0;
    NSInteger totalOffsetInSecondsForUnmute = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now];
    NSDate *begin = [BBA_PreferenceController preferenceBeginDate];
    NSDateComponents *beginComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:begin];
    NSDate *end = [BBA_PreferenceController preferenceEndDate];
    NSDateComponents *endComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:end];
    
    int beginInSeconds = (int)([beginComponents hour] * 60 * 60 + [beginComponents minute] * 60 + [beginComponents second]);
    int endInSeconds = (int)([endComponents hour] * 60 * 60 + [endComponents minute] * 60 + [endComponents second]);
    int nowInSeconds = (int)([nowComponents hour] * 60 * 60 + [nowComponents minute] * 60 + [nowComponents second]);
    
    totalOffsetInSecondsForMute = (beginInSeconds - nowInSeconds) % (60 * 60 * 60);
    if (totalOffsetInSecondsForMute < 0) totalOffsetInSecondsForMute += (60 * 60 * 60); // objC does not prevent negative modulus.

    totalOffsetInSecondsForUnmute = (endInSeconds - nowInSeconds) % (60 * 60 * 60);
    if (totalOffsetInSecondsForUnmute < 0) totalOffsetInSecondsForUnmute += (60 * 60 * 60); // objC does not prevent negative modulus.
    
    [self performSelector:@selector(mute) withObject:self afterDelay:totalOffsetInSecondsForMute];
    [self performSelector:@selector(unmute) withObject:self afterDelay:totalOffsetInSecondsForUnmute];
}

@end
