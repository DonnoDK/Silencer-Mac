//
//  BBA_PreferencesController.m
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import "BBA_PreferenceController.h"
//#import "LaunchAtLoginController.h"

@implementation BBA_PreferenceController
//@synthesize launchAtLoginCheckbox;


- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    
    return self;
}

#pragma mark Accessors

- (void)windowDidLoad {
    [self setBegin:[BBA_PreferenceController preferenceBeginDate]];
    [self setEnd:[BBA_PreferenceController preferenceEndDate]];
    /*
    LaunchAtLoginController *launcher = [[LaunchAtLoginController alloc] init];
    if ([launcher launchAtLogin]) {
        [self setLaunchAtLoginCheckbox:YES];
    }
    else {
        [self setLaunchAtLoginCheckbox:NO];
    }
    */
}

- (void)setBegin:(NSDate *)b {
    [self willChangeValueForKey:@"begin"];
    begin = b;
    [self didChangeValueForKey:@"begin"];
    [[NSUserDefaults standardUserDefaults] setObject:b forKey:@"begin"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification:[NSNotification notificationWithName:@"updateScheduler" object:nil]];
}

- (NSDate *)begin {
    return begin;
}

- (void)setEnd:(NSDate *)e {
    [self willChangeValueForKey:@"end"];
    end = e;
    [self didChangeValueForKey:@"end"];
    [[NSUserDefaults standardUserDefaults] setObject:e forKey:@"end"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification:[NSNotification notificationWithName:@"updateScheduler" object:nil]];
}

- (NSDate *)end {
    return end;
}

#pragma mark UserDefaults


+ (NSDate *)preferenceBeginDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"begin"];
}

+ (NSDate *)preferenceEndDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"end"];
}
/*
- (IBAction)launchAtLogin:(id)sender {
    LaunchAtLoginController *launcher = [[LaunchAtLoginController alloc] init];
    [launcher setLaunchAtLogin:![launcher launchAtLogin]];
}
*/

@end
