//
//  UULogger.h
//  UULogger
//
//  Created by xiaoda on 2023/12/17.
//  Copyright © 2023 UUSafe. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMLog : DDLog

/// 创建日志
/// - Parameters:
///   - directory: 日志文件存放目录
///   - key: AES-256-CBC 加密key
///   - iv: AES-256-CBC 加密iv
+ (void)createLogWithDirectory:(NSString *)directory
                           key:(nullable NSString *)key
                            iv:(nullable NSString *)iv;

/// 创建日志
/// - Parameters:
///   - directory: 日志文件存放目录
///   - filename: 文件名
///   - context: 上下文
///   - key: AES-256-CBC 加密key
///   - iv: AES-256-CBC 加密iv
+ (void)createLogWithDirectory:(NSString *)directory
                      filename:(NSString *)filename
                       context:(NSInteger)context
                           key:(nullable NSString *)key
                            iv:(nullable NSString *)iv;

/// 创建日志
/// - Parameters:
///   - directory: 日志文件存放目录
///   - encrypt: 加密实现
+ (void)createLogWithDirectory:(NSString *)directory
                       encrypt:(nullable NSData * _Nullable (^)(NSData *_Nullable plaintext))encrypt;

/// 创建日志
/// - Parameters:
///   - directory: 日志文件存放目录
///   - filename: 文件名
///   - context: 上下文
///   - encrypt: 加密实现
+ (void)createLogWithDirectory:(NSString *)directory
                      filename:(NSString *)filename
                       context:(NSInteger)context
                       encrypt:(nullable NSData * _Nullable (^)(NSData *_Nullable plaintext))encrypt;


/// 日志级别，默认Verbose
@property (class, nonatomic) DDLogLevel logLevel;

/// 设置是否输出到控制台
/// - Parameter console: 控制台开关 YES-开 NO-关
+ (void)setLogConsole:(BOOL)console;

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
