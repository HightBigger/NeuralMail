//
//  NMLogUtils.m
//  UULog
//
//  Created by xiaoda on 2024/1/4.
//  Copyright © 2024 UUSafe. All rights reserved.
//

#import "NMLogUtils.h"

typedef size_t CCKeySize;

@implementation NMLogUtils

#pragma mark - AES Encrypt

/// AES-256 Encrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 明文
/// @param key 加密key 不足32字节的末尾填充'\0'补齐到32字节，超过32字节的截取前32字节
/// @param iv 加密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options 加密选项
+ (NSData *)AES256EncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options
{
    return [self AESEncryptData:data key:key keyLength:kCCKeySizeAES256 iv:iv options:options];
}

/// AES Encrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 明文
/// @param key 加密key
/// @param keyLength 指定key长度 0:根据key的字节数选择对应的加密方式 不为0: 根据keyLength选择对应的加密方式
/// @param iv 加密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options 加密选项
+ (NSData *)AESEncryptData:(NSData *)data key:(NSString *)key keyLength:(CCKeySize)keyLength iv:(NSString *)iv options:(CCOptions)options
{
    return [self cryptWithOperation:kCCEncrypt algorithm:kCCAlgorithmAES data:data key:key keyLength:keyLength iv:iv options:options];
}

#pragma mark - AES Decrypt

/// AES-256 Decrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 密文
/// @param key 解密key 不足32字节的末尾填充'\0'补齐到32字节，超过32字节的截取前32字节
/// @param iv 解密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options options 解密选项
+ (NSData *)AES256DecryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options
{
    return [self AESDecryptData:data key:key keyLength:kCCKeySizeAES256 iv:iv options:options];
}

/// AES Decrypt 默认为CBC模式，ECB模式iv参数失效
/// @param data 密文
/// @param key 解密key
/// @param keyLength 指定key长度 0:根据key的字节数选择对应的解密密方式 不为0: 根据keyLength选择对应的解密密方式
/// @param iv 解密向量 不足16字节的末尾填充'\0'补齐到16字节，超过16字节的截取前16字节
/// @param options 解密选项
+ (NSData *)AESDecryptData:(NSData *)data key:(NSString *)key keyLength:(CCKeySize)keyLength iv:(NSString *)iv options:(CCOptions)options
{
    return [self cryptWithOperation:kCCDecrypt algorithm:kCCAlgorithmAES data:data key:key keyLength:keyLength iv:iv options:options];
}

#pragma mark - AES/3DES

+ (NSData *)cryptWithOperation:(CCOperation)op algorithm:(CCAlgorithm)algorithm data:(NSData *)data key:(NSString *)key keyLength:(CCKeySize)keyLength iv:(NSString *)iv options:(CCOptions)options
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    int blockSize = 0;
    // AES或3DES
    if (algorithm == kCCAlgorithmAES || algorithm == kCCAlgorithm3DES)
    {
        size_t bufferSize = 0;
        NSUInteger dataLength = data.length;
        if (algorithm == kCCAlgorithmAES)
        {
            blockSize = kCCBlockSizeAES128;
            if (keyLength == 0)
            {
                // key小于等于16字节 AES128
                if (keyData.length <= 16)
                {
                    keyLength = kCCKeySizeAES128;
                } // key小于等于24字节 AES192
                else if (keyData.length <= 24)
                {
                    keyLength = kCCKeySizeAES192;
                } // key大于等于32字节 AES256
                else
                {
                    keyLength = kCCKeySizeAES256;
                }
            }
        }
        else
        {
            blockSize = kCCBlockSize3DES;
            keyLength = kCCKeySize3DES;
        }
        bufferSize = (dataLength + blockSize) & ~(blockSize - 1);
        char keyPtr[keyLength];
        memset(keyPtr, 0, sizeof(keyPtr));
        NSUInteger length = keyData.length > keyLength ? keyLength : keyData.length;
        [keyData getBytes:keyPtr length:length];
        
        void *buffer = malloc(bufferSize);
        size_t numBytes = 0;
        CCCryptorStatus cryptStatus = kCCSuccess;
        if ((options & kCCOptionECBMode) == 0)
        {
            char ivPtr[blockSize];
            memset(ivPtr, 0, sizeof(ivPtr));
            NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
            length = ivData.length > blockSize ? blockSize : ivData.length;
            [ivData getBytes:ivPtr length:length];
            cryptStatus = CCCrypt(op, algorithm, options, keyPtr, keyLength, ivPtr, data.bytes, dataLength, buffer, bufferSize, &numBytes);
        }
        else
        {
            cryptStatus = CCCrypt(op, algorithm, options, keyPtr, keyLength, NULL, data.bytes, dataLength, buffer, bufferSize, &numBytes);
        }
        if (cryptStatus == kCCSuccess)
        {
            return [NSData dataWithBytesNoCopy:buffer length:numBytes freeWhenDone:YES];
        }
        free(buffer);
    }
    
    return nil;
}

@end
