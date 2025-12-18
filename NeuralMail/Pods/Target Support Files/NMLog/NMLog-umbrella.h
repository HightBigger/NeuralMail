#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NMLog.h"
#import "NMLogBridge.h"
#import "NMLogger.h"
#import "NMLogMacros.h"

FOUNDATION_EXPORT double NMLogVersionNumber;
FOUNDATION_EXPORT const unsigned char NMLogVersionString[];

