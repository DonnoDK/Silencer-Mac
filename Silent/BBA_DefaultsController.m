//
//  BBA_DefaultsController.m
//  Silencer
//
//  Created by Pétur Ingi Egilsson on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_DefaultsController.h"

// Keys for user defaults.
NSString * const kMuteDate = @"mute";
NSString * const kUnmuteDate = @"unmute";

@implementation BBA_DefaultsController

// Reads the current mute date.
+ (NSDate *)preferenceBeginDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMuteDate];
}

// Reads the current unmute date.
+ (NSDate *)preferenceEndDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUnmuteDate];
}

// Saves obj for key into defaults.
+ (void)setObject:(id)obj forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
}

// Registers the defaults.
+ (void)registerDefaults {
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
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
    
    [defaultValues setObject:startDate forKey:kMuteDate];
    [defaultValues setObject:endDate forKey:kUnmuteDate];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

@end
