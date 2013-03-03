//
//  BBA_Logger.h
//  Silencer
//
//  Created by Brian Pedersen on 02/03/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

// Enum for log levels. Remember to add an associated string in the .m file
typedef enum BBA_LOG_LEVEL{
    BBA_EMERGENCY = 0,
    BBA_ALERT,
    BBA_CRITICAL,
    BBA_ERROR,
    BBA_WARNING,
    BBA_NOTICE,
    BBA_INFO,
    BBA_DEBUG
}BBA_LOG_LEVEL;

// The logger class
@interface BBA_Logger : NSObject{
    // path to the logfile
    NSString *pathForLogfile;
    // pointer/handle to the logfile
    NSFileHandle *logfile;
    // mutex for thread-safety
    NSLock *mutex;
}
+(BBA_Logger*)sharedInstance;
@end

// C-like function for logging. This is on purpose to make it look like NSLog(...)
void BBALog(NSString* message, BBA_LOG_LEVEL level, id sender);