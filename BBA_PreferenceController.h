//
//  BBA_PreferencesController.h
//  Silent
//
//  Created by Pétur Egilsson on 21/06/12.
//  Copyright (c) 2012 Bluebird Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BBA_PreferenceController : NSWindowController {
    NSDate *mute;
    NSDate *unmute;
}

- (void)setMute:(NSDate *)b;
- (void)setUnmute:(NSDate *)e;

@end
