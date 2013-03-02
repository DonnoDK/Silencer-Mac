//
//  BBA_DefaultsController.h
//  Silencer
//
//  Created by Pétur Ingi Egilsson on 22/02/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

// Defaults
extern NSString * const kMuteDate;
extern NSString * const kUnmuteDate;

@interface BBA_DefaultsController : NSObject

+ (NSDate *)preferenceBeginDate;
+ (NSDate *)preferenceEndDate;
+ (void)registerDefaults;
+ (void)setObject:(id)obj forKey:(NSString *)key;

@end
