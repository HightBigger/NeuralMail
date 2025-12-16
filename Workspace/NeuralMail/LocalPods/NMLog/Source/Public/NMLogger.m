//
//  UULogger.m
//  UULogger
//
//  Created by xiaoda on 2023/12/17.
//  Copyright © 2023 UUSafe. All rights reserved.
//

#import "NMLogger.h"
#import "NMFileLogger.h"

#pragma mark - UUOSLogger

@interface UUOSLogger : DDOSLogger

@end

@implementation UUOSLogger

+ (instancetype)sharedInstance
{
    static UUOSLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

@end

#pragma mark - UULog

@implementation NMLog

static DDLogLevel uuLogLevel = DDLogLevelVerbose;

+ (instancetype)sharedInstance 
{
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

+ (void)createLogWithDirectory:(NSString *)directory key:(NSString *)key iv:(NSString *)iv
{
    [self createLogWithDirectory:directory filename:nil context:0 key:key iv:iv encrypt:nil];
}

+ (void)createLogWithDirectory:(NSString *)directory filename:(NSString *)filename context:(NSInteger)context key:(NSString *)key iv:(NSString *)iv
{
    [self createLogWithDirectory:directory filename:filename context:context key:key iv:iv encrypt:nil];
}

+ (void)createLogWithDirectory:(NSString *)directory encrypt:(NSData * _Nullable (^)(NSData * _Nullable))encrypt
{
    [self createLogWithDirectory:directory filename:nil context:0 key:nil iv:nil encrypt:encrypt];
}

+ (void)createLogWithDirectory:(NSString *)directory filename:(NSString *)filename context:(NSInteger)context encrypt:(NSData * _Nullable (^)(NSData * _Nullable))encrypt
{
    [self createLogWithDirectory:directory filename:filename context:context key:nil iv:nil encrypt:encrypt];
}

+ (void)createLogWithDirectory:(NSString *)directory
                      filename:(NSString *)filename
                       context:(NSInteger)context
                           key:(nullable NSString *)key
                            iv:(nullable NSString *)iv
                       encrypt:(nullable NSData * _Nullable (^)(NSData * _Nullable))encrypt
{
    NMLogFileManager *fileManager = [[NMLogFileManager alloc] initWithLogsDirectory:directory];
    fileManager.filename = filename;
    NMFileLogger *fileLogger = [[NMFileLogger alloc] initWithLogFileManager:fileManager];
    fileLogger.context = context;
    fileLogger.key = key;
    fileLogger.iv = iv;
    fileLogger.encrypt = encrypt;
    [NMLog addLogger:fileLogger];
}

+ (DDLogLevel)logLevel
{
    return uuLogLevel;
}

+ (void)setLogLevel:(DDLogLevel)level
{
    uuLogLevel = level;
}

+ (void)setLogConsole:(BOOL)console
{
    NSArray<id<DDLogger>> *allLoggers = [NMLog allLoggers];
    UUOSLogger *osLogger = (UUOSLogger *)[UUOSLogger sharedInstance];
    BOOL found = [allLoggers containsObject:osLogger];
    if (console)
    {
        if (!found)
        {
            [NMLog addLogger:osLogger];
        }
    }
    else
    {
        if (found)
        {
            [NMLog removeLogger:osLogger];
        }
    }
}

+ (void)setLogFlag:(BOOL)flag
{
    [NMFileLogger setLogFlag:flag];
}

+ (void)setLogMaxFileSize:(uint64_t)maxFileSize
{
    [NMFileLogger setLogMaxFileSize:maxFileSize];
}

+ (void)setLogRollingFrequency:(NSTimeInterval)rollingFrequency
{
    [NMFileLogger setLogRollingFrequency:rollingFrequency];
}

+ (void)setLogMaxNumLogFiles:(NSInteger)maxNumLogFiles
{
    [NMFileLogger setLogMaxNumLogFiles:maxNumLogFiles];
}

+ (void)setLogFilesDiskQuota:(uint64_t)filesDiskQuota
{
    [NMFileLogger setLogFilesDiskQuota:filesDiskQuota];
}

@end
