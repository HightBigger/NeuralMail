//
//  NMFileLogger.h
//  UULog
//
//  Created by xiaoda on 2023/12/5.
//  Copyright © 2023 UUSafe. All rights reserved.
//

#import <CocoaLumberjack/DDFileLogger.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMLogFileManager : DDLogFileManagerDefault
/// 文件名
@property (copy, nonatomic) NSString *filename;

@end


/// 默认使用AES-256-CBC加密，设置key和iv即可
/// 可通过设置encrypt实现加密，两种都存在，encrypt优先
@interface NMFileLogger : DDFileLogger
/// 上下文
@property (nonatomic) NSInteger context;
/// 日志加密key 32字节
@property (copy, nonatomic) NSString *key;
/// 日志加密iv 16字节
@property (copy, nonatomic) NSString *iv;
/// 日志加密block实现
@property (copy, nonatomic, nullable) NSData * _Nullable (^encrypt)(NSData *_Nullable plaintext);

/// 是否打印日志级别 比如: [Info] [Debug] ... 注：在创建日志之前调用
/// - Parameter flag: 开关
+ (void)setLogFlag:(BOOL)flag;

/// 设置日志单个文件大小上限，默认5M 注：在创建日志之前调用
/// - Parameter maxFileSize: 单个文件大小上限
+ (void)setLogMaxFileSize:(uint64_t)maxFileSize;

/// 设置日志文件周期，默认24小时 注：在创建日志之前调用
/// - Parameter rollingFrequency: 文件周期
+ (void)setLogRollingFrequency:(NSTimeInterval)rollingFrequency;

/// 设置文件最大数目，默认10 注：在创建日志之前调用
/// - Parameter maxNumLogFiles: 文件最大数目
+ (void)setLogMaxNumLogFiles:(NSInteger)maxNumLogFiles;

/// 设置日志占用磁盘总大小，默认50M 注：在创建日志之前调用
/// - Parameter filesDiskQuota: 日志占用磁盘总大小
+ (void)setLogFilesDiskQuota:(uint64_t)filesDiskQuota;

@end

NS_ASSUME_NONNULL_END
