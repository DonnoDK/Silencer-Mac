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

- (id)init {
    self = [super init];
    
    if (self) {
        audioDevicecontroller = [[BBA_AudioDeviceController alloc] init];
    }
    
    return self;
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

- (IBAction)emailSupport:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://bluebirdapps.dk/contact/"]];
}

#pragma mark Mute Functions

- (void)mute {
    [self updateScheduler]; // Mute again in 24 hours.
    NSLog(@"Muted at %@\n", [NSDate date]);
    
    [audioDevicecontroller muteAllDevices];
}

- (void)unmute {
    [self updateScheduler]; // Unmute again in 24 hours.
    NSLog(@"Unmuted at %@\n", [NSDate date]);
    
    [audioDevicecontroller unmuteAllDevices];
}

- (void)updateScheduler {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now = [NSDate date];
    NSDateComponents *nowComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now];
    
    NSDate *begin = [BBA_DefaultsController preferenceBeginDate];
    NSDateComponents *beginComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:begin];
    
    NSDate *end = [BBA_DefaultsController preferenceEndDate];
    NSDateComponents *endComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:end];
    
    // Calculates the begin, end and now time as seconds from midnight.
    int beginInSeconds = (int)([beginComponents hour] * 60 * 60 + [beginComponents minute] * 60 + [beginComponents second]);
    int endInSeconds = (int)([endComponents hour] * 60 * 60 + [endComponents minute] * 60 + [endComponents second]);
    int nowInSeconds = (int)([nowComponents hour] * 60 * 60 + [nowComponents minute] * 60 + [nowComponents second]);
    
    NSInteger totalOffsetInSecondsForMute = beginInSeconds - nowInSeconds;
    NSInteger totalOffsetInSecondsForUnmute = endInSeconds - nowInSeconds;
    
    /*
     *  If the begin or end times are less than the current time then schedule their action for the next day.
     *  The equal sign is used to prevent the scheduled task from executing multipl times during the current scheduled second.
     */
    const int SECONDS_IN_A_DAY = 60 * 60 * 24;
    if (beginInSeconds <= nowInSeconds)
        totalOffsetInSecondsForMute += SECONDS_IN_A_DAY;
    if (endInSeconds <= nowInSeconds)
        totalOffsetInSecondsForUnmute += SECONDS_IN_A_DAY;
    
    NSLog(@"\n");
    NSLog(@"Will mute in %ld seconds.\n", totalOffsetInSecondsForMute);
    NSLog(@"Will unmute in %ld seconds.\n", totalOffsetInSecondsForUnmute);
    NSLog(@"\n");
     
    // Cancel any previous requests then create a new request.
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(mute) withObject:self afterDelay:totalOffsetInSecondsForMute];
    [self performSelector:@selector(unmute) withObject:self afterDelay:totalOffsetInSecondsForUnmute];
    
}

@end
