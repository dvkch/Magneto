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

#import "SPLPing.h"
#import "SPLPingConfiguration.h"
#import "SPLPingResponse.h"

FOUNDATION_EXPORT double SPLPingVersionNumber;
FOUNDATION_EXPORT const unsigned char SPLPingVersionString[];

