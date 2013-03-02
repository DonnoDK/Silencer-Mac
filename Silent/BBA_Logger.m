//
//  BBA_Logger.m
//  Silencer
//
//  Created by Brian Pedersen on 02/03/13.
//  Copyright (c) 2013 Bluebird Apps. All rights reserved.
//

#import "BBA_Logger.h"
#define TO_LOG_FILE

@implementation BBA_Logger

+(BBA_Logger*)sharedInstance{
    // This is ugly BUT thread safe code when using the singleton pattern
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithLogfileFilename:@"Silencer.log"];
    });
    return _sharedObject;
}

-(id)init{
    assert(false && "Unable to instantiate using -(id)init");
}


-(void)bbaLog:(NSString*)message atLogLevel:(BBA_LOG_LEVEL)logLevel inClass:(id)theClass{
    NSDate *now = [NSDate date];
    NSString *loglevelString = [self determineLoglevelString:logLevel];
    NSString *className = NSStringFromClass([theClass class]);
    NSString *logString = [NSString stringWithFormat:@"[DATE: %@][LEVEL: %@][CLASS: %@] Message: %@\n",now,loglevelString,className,message];
    [self writeToFile:logString];
}

-(void)writeToFile:(NSString*)logString{
    logfile = [NSFileHandle fileHandleForWritingAtPath:pathForLogfile];
    [logfile seekToEndOfFile];
    [logfile writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    [logfile synchronizeFile];
    [logfile closeFile];
}

-(NSString*)determineLoglevelString:(BBA_LOG_LEVEL)logLevel{
    NSString *levelString;
    switch (logLevel) {
        case BBA_EMERGENCY:
            levelString = @"EMERGENCY";
            break;
        case BBA_ALERT:
            levelString = @"ALERT";
            break;
        case BBA_CRITICAL:
            levelString = @"CRITICAL";
            break;
        case BBA_ERROR:
            levelString = @"ERROR";
            break;
        case BBA_WARNING:
            levelString = @"WARNING";
            break;
        case BBA_NOTICE:
            levelString = @"NOTICE";
            break;
        case BBA_INFO:
            levelString = @"INFO";
            break;
        case BBA_DEBUG:
            levelString = @"DEBUG";
            break;
        default:
            break;
    }
    return levelString;
}
//private 'hidden' init method
-(id)initWithLogfileFilename:(NSString*)filename{
    self = [super init];
    if(self){
        NSString *path = [NSString stringWithFormat:@"Library/Logs/%@",filename];
        pathForLogfile = [NSHomeDirectory() stringByAppendingPathComponent:path];
        logfile = [NSFileHandle fileHandleForWritingAtPath:pathForLogfile];
        if(!logfile){
            [[NSFileManager defaultManager]createFileAtPath:pathForLogfile contents:nil attributes:nil];
            logfile = [NSFileHandle fileHandleForWritingAtPath:pathForLogfile];
        }
    }
    return self;
}
@end

void BBALog(NSString* message, BBA_LOG_LEVEL level, id sender){
    BBA_Logger *loggerInstance = [BBA_Logger sharedInstance];
    [loggerInstance bbaLog:message atLogLevel:level inClass:sender];
}

