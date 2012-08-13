//
//  BBA_PreferencesController.h
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBA_PreferenceController : NSWindowController {
    NSDate *begin;
    NSDate *end;
}

//@property bool launchAtLoginCheckbox;

+ (NSDate *)preferenceBeginDate;
+ (NSDate *)preferenceEndDate;

//- (IBAction)launchAtLogin:(id)sender;

@end
