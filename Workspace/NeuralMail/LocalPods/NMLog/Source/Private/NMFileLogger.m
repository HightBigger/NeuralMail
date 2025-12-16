//
//  NMFileLogger.m
//  UULog
//
//  Created by xiaoda on 2023/12/5.
//  Copyright © 2023 UUSafe. All rights reserved.
//

#import "NMFileLogger.h"
#import <objc/message.h>
#import "NMLogUtils.h"

static BOOL            uuLogFlag               = NO;
static uint64_t        uuLogMaxFileSize        = 1024 * 1024 * 5;
static NSTimeInterval  uuLogRollingFrequency   = 60 * 60 * 24;
static NSUInteger      uuLogMaxNumLogFiles     = 10;
static uint64_t        uuLogFilesDiskQuota     = 1024 * 1024 * 50;

#pragma mark - NMLogFileManager

@implementation NMLogFileManager

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory
{
    self = [super initWithLogsDirectory:logsDirectory];
    if (self)
    {
        self.maximumNumberOfLogFiles = uuLogMaxNumLogFiles;
        self.logFilesDiskQuota = uuLogFilesDiskQuota;
        
        NSDateFormatter *dateFormatter = ((NSDateFormatter * (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"logFileDateFormatter"));
        [dateFormatter setLocale:nil];
        [dateFormatter setTimeZone:nil];
        [dateFormatter setDateFormat: @"yyyy_MM_dd_HH_mm_ss_SSS"];
    }
    
    return self;
}

- (NSString *)newLogFileName
{
    NSString *prefix = self.filename;
    if (prefix.length == 0)
    {
        prefix = ((NSString * (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"applicationName"));
    }
    
    NSDateFormatter *dateFormatter = ((NSDateFormatter * (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"logFileDateFormatter"));
    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@_%@.ulog", prefix, formattedDate];
}

- (BOOL)isLogFile:(NSString *)fileName
{
    NSString *prefix = self.filename;
    if (prefix.length == 0)
    {
        prefix = ((NSString * (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"applicationName"));
    }
    
    BOOL hasProperPrefix = [fileName hasPrefix:[prefix stringByAppendingString:@"_"]];
    BOOL hasProperSuffix = [fileName hasSuffix:@".ulog"];

    return (hasProperPrefix && hasProperSuffix);
}

@end

#pragma mark - UULogFileFormatter

@interface UULogFileFormatter : NSObject <DDLogFormatter>
/// 日志打印级别开关
@property (nonatomic) BOOL flag;

/**
 *  Default initializer
 */
- (instancetype)init;

/**
 *  Designated initializer, requires a date formatter
 */
- (instancetype)initWithDateFormatter:(nullable NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

@end

@interface UULogFileFormatter ()
{
    NSDateFormatter *_dateFormatter;
}

@end

@implementation UULogFileFormatter

- (instancetype)init
{
    return [self initWithDateFormatter:nil];
}

- (instancetype)initWithDateFormatter:(nullable NSDateFormatter *)aDateFormatter
{
    if ((self = [super init]))
    {
        if (aDateFormatter)
        {
            _dateFormatter = aDateFormatter;
        }
        else
        {
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4]; // 10.4+ style
            [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        }
    }

    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *dateAndTime = [_dateFormatter stringFromDate:logMessage->_timestamp];
    NSString *flag = self.flag ? [NSString stringWithFormat:@"[%@] ", [self flagToString:logMessage.flag]] : @"";
    NSString *tag = @"";
    
    if ([logMessage.representedObject isKindOfClass:[NSString class]] && [logMessage.representedObject length] > 0)
    {
        tag = [NSString stringWithFormat:@"[%@] ", logMessage.representedObject];
    }
    
    return [NSString stringWithFormat:@"%@ %@%@%@:%lu %@ %@", dateAndTime, flag, tag, logMessage.fileName, logMessage.line, logMessage.function, logMessage->_message];
}

- (NSString *)flagToString:(DDLogFlag)flag
{
    switch (flag)
    {
        case DDLogFlagError:
            return @"Error";
        case DDLogFlagWarning:
            return @"Warn";
        case DDLogFlagInfo:
            return @"Info";
        case DDLogFlagDebug:
            return @"Debug";
        case DDLogFlagVerbose:
            return @"Verbose";
        default:
            return @"Unknown";
    }
}

@end

#pragma mark - NMFileLogger

@implementation NMFileLogger

- (instancetype)init
{
    NMLogFileManager *defaultLogFileManager = [[NMLogFileManager alloc] init];
    return [self initWithLogFileManager:defaultLogFileManager completionQueue:nil];
}

- (instancetype)initWithLogFileManager:(id<DDLogFileManager>)logFileManager completionQueue:(dispatch_queue_t)dispatchQueue
{
    self = [super initWithLogFileManager:logFileManager completionQueue:dispatchQueue];
    if (self)
    {
        self.maximumFileSize = uuLogMaxFileSize;
        self.rollingFrequency = uuLogRollingFrequency;

        UULogFileFormatter *formatter = [UULogFileFormatter new];
        formatter.flag = uuLogFlag;
        _logFormatter = formatter;
    }
    
    return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    if (logMessage.context != self.context)
    {
        return;
    }
    NSData *data = ((NSData * (*)(id, SEL, DDLogMessage *))objc_msgSend)(self, NSSelectorFromString(@"lt_dataForMessage:"), logMessage);
    
    if (data.length == 0)
    {
        return;
    }
    
    if (self.encrypt)
    {
        data = self.encrypt(data);
    }
    else if (self.key.length > 0 && self.iv.length > 0)
    {
        data = [self encryptData:data];
    }

    ((void (*)(id, SEL, NSData *))objc_msgSend)(self, NSSelectorFromString(@"lt_logData:"), data);
}

// AES-256-CBC
- (NSData *)encryptData:(NSData *)data
{
    NSUInteger blockSize = 128;
    NSUInteger len = data.length;
    NSUInteger rows = len / blockSize;
    NSUInteger remainder = len % blockSize;
    if (remainder != 0)
    {
        rows++;
    }
    NSMutableData *bufData = [NSMutableData dataWithLength:blockSize * rows];
    [bufData replaceBytesInRange:NSMakeRange(0, len) withBytes:data.bytes];
    for (int i = 0; i < rows; i++)
    {
        NSRange range = NSMakeRange(i * blockSize, blockSize);
        NSData *subData = [bufData subdataWithRange:NSMakeRange(i * blockSize, blockSize)];
        NSData *cipherData = [NMLogUtils AES256EncryptData:subData key:self.key iv:self.iv options:0];
        [bufData replaceBytesInRange:range withBytes:cipherData.bytes];
    }
    
    return bufData;
}

+ (void)setLogFlag:(BOOL)flag
{
    uuLogFlag = flag;
}

+ (void)setLogMaxFileSize:(uint64_t)maxFileSize
{
    uuLogMaxFileSize = maxFileSize;
}

+ (void)setLogRollingFrequency:(NSTimeInterval)rollingFrequency
{
    uuLogRollingFrequency = rollingFrequency;
}

+ (void)setLogMaxNumLogFiles:(NSInteger)maxNumLogFiles
{
    uuLogMaxNumLogFiles = maxNumLogFiles;
}

+ (void)setLogFilesDiskQuota:(uint64_t)filesDiskQuota
{
    uuLogFilesDiskQuota = filesDiskQuota;
}

@end
