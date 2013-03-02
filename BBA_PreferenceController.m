//
//  BBA_PreferencesController.m
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//
//  This class is responsable for the Preferences UI.

#import "BBA_PreferenceController.h"
#import "BBA_DefaultsController.h"
#import "BBA_Logger.h"

@implementation BBA_PreferenceController

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    
    return self;
}

- (void)windowDidLoad {
    
    // Puts the correct values into the UI before it is shown.
    [self setMute:[BBA_DefaultsController preferenceBeginDate]];
    [self setUnmute:[BBA_DefaultsController preferenceEndDate]];
}

// Posts a notification because the date values have been changed.
- (void)postDateChangedNotification {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification:[NSNotification notificationWithName:@"dateObjectHasChanged" object:nil]];
}

#pragma mark Setters

- (void)setMute:(NSDate *)b {
    
    // Variable setter code.
    [self willChangeValueForKey:@"mute"];
    mute = b;
    [self didChangeValueForKey:@"mute"];
    
    // Sets the new date object as shared defaults.
    [BBA_DefaultsController setObject:b forKey:kMuteDate];
    
    
    
    // Post a notification so the mute/unmuter can take the new date into account.
    [self postDateChangedNotification];
}

- (void)setUnmute:(NSDate *)e {
    
    // Variable setter code.
    [self willChangeValueForKey:@"unmute"];
    unmute = e;
    [self didChangeValueForKey:@"unmute"];
    
    // Sets the new date object as shared defaults.
    [BBA_DefaultsController setObject:e forKey:kUnmuteDate];
    
    BBALog([NSString stringWithFormat:@"Unmute set to %@", e], BBA_INFO, self);
    
    // Post a notification so the mute/unmuter can take the new date into account.
    [self postDateChangedNotification];
}

@end
