//
//  NMLogMacros.h
//  NMLog
//
//  Created by xiaoda on 2023/12/5.
//  Copyright © 2023 UUSafe. All rights reserved.
//

#import "NMLogger.h"

#ifndef NM_LOG_LEVEL_DEF
    #define NM_LOG_LEVEL_DEF [NMLog logLevel]
#endif

#ifndef NM_LOG_ASYNC_ENABLED
    #define NM_LOG_ASYNC_ENABLED YES
#endif

#define NM_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [NMLog log : isAsynchronous                                        \
             level : lvl                                                   \
              flag : flg                                                   \
           context : ctx                                                   \
              file : __FILE_NAME__                                         \
          function : fnct                                                  \
              line : __LINE__                                              \
               tag : atag                                                  \
            format : (frmt), ## __VA_ARGS__]

#define NM_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if((lvl & flg) != 0) NM_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define NM_LOG(async, flg, ctx, tag, frmt, ...) NM_LOG_MAYBE(async, NM_LOG_LEVEL_DEF, flg, ctx, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define NM_LOG_Error(ctx, tag, frmt, ...)   NM_LOG(NO,                   DDLogFlagError,   ctx, tag, frmt, ##__VA_ARGS__)
#define NM_LOG_Warn(ctx, tag, frmt, ...)    NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagWarning, ctx, tag, frmt, ##__VA_ARGS__)
#define NM_LOG_Info(ctx, tag, frmt, ...)    NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagInfo,    ctx, tag, frmt, ##__VA_ARGS__)
#define NM_LOG_Debug(ctx, tag, frmt, ...)   NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagDebug,   ctx, tag, frmt, ##__VA_ARGS__)
#define NM_LOG_Verbose(ctx, tag, frmt, ...) NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagVerbose, ctx, tag, frmt, ##__VA_ARGS__)

#define NMLogError(frmt, ...)   NM_LOG(NO,                   DDLogFlagError,   0, nil, frmt, ##__VA_ARGS__)
#define NMLogWarn(frmt, ...)    NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagWarning, 0, nil, frmt, ##__VA_ARGS__)
#define NMLogInfo(frmt, ...)    NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagInfo,    0, nil, frmt, ##__VA_ARGS__)
#define NMLogDebug(frmt, ...)   NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagDebug,   0, nil, frmt, ##__VA_ARGS__)
#define NMLogVerbose(frmt, ...) NM_LOG(NM_LOG_ASYNC_ENABLED, DDLogFlagVerbose, 0, nil, frmt, ##__VA_ARGS__)
