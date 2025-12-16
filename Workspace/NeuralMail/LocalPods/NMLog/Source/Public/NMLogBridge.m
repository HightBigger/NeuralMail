//
//  NMLogBridge.m
//  NMLog
//
//  Created by 小大 on 2025/12/11.
//

#import "NMLogBridge.h"

@implementation NMLogBridge

+ (void)logInfoWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message
{
    [NMLog log:YES level:[NMLog logLevel] flag:DDLogFlagInfo context:0 file:file.UTF8String function:function.UTF8String line:line tag:tag format:@"%@",message];
}

+ (void)logWranWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message
{
    [NMLog log:YES level:[NMLog logLevel] flag:DDLogFlagWarning context:0 file:file.UTF8String function:function.UTF8String line:line tag:tag format:@"%@",message];
}

+ (void)logDebugWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message
{
    [NMLog log:NO level:[NMLog logLevel] flag:DDLogFlagDebug context:0 file:file.UTF8String function:function.UTF8String line:line tag:tag format:@"%@",message];
}

+ (void)logErrorWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message
{
    [NMLog log:YES level:[NMLog logLevel] flag:DDLogFlagError context:0 file:file.UTF8String function:function.UTF8String line:line tag:tag format:@"%@",message];
}

@end
