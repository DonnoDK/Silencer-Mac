//
//  BBA_Logger.h
//  Silencer
//
//  Created by Brian Pedersen on 02/03/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBA_Logger : NSObject{
    NSString *pathForLogfile;
    NSFileHandle *logfile;
    
}
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

+(BBA_Logger*)sharedInstance;

-(void)bbaLog:(NSString*)message atLogLevel:(BBA_LOG_LEVEL)logLevel inClass:(id)theClass;

@end

void BBALog(NSString* message, BBA_LOG_LEVEL level, id sender);