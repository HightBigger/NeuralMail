//
//  NMLogUtils.h
//  UULog
//
//  Created by xiaoda on 2024/1/4.
//  Copyright © 2024 UUSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMLogUtils : NSObject

#pragma mark - AES Encrypt

/// AES-256 Encrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 明文
/// @param key 加密key 不足32字节的末尾填充'\0'补齐到32字节，超过32字节的截取前32字节
/// @param iv 加密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options 加密选项
+ (nullable NSData *)AES256EncryptData:(NSData *)data key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

#pragma mark - AES Decrypt

/// AES-256 Decrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 密文
/// @param key 解密key 不足32字节的末尾填充'\0'补齐到32字节，超过32字节的截取前32字节
/// @param iv 解密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options options 解密选项
+ (nullable NSData *)AES256DecryptData:(NSData *)data key:(NSString *)key iv:(nullable NSString *)iv options:(CCOptions)options;

@end

NS_ASSUME_NONNULL_END
