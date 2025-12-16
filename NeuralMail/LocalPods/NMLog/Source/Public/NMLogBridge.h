//
//  NMLogBridge.h
//  NMLog
//
//  Created by 小大 on 2025/12/11.
//

#import <Foundation/Foundation.h>
#import "NMLogMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMLogBridge : NSObject

+ (void)logInfoWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message;
+ (void)logWranWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message;
+ (void)logDebugWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message;
+ (void)logErrorWithTag:(NSString *)tag file:(NSString *)file function:(NSString *)function line:(int32_t)line message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
