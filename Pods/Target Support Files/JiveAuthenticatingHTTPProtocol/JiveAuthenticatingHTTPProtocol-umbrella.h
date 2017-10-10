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

#import "JAHPAuthenticatingHTTPProtocol.h"
#import "JAHPCacheStoragePolicy.h"
#import "JAHPCanonicalRequest.h"
#import "JAHPQNSURLSessionDemux.h"

FOUNDATION_EXPORT double JiveAuthenticatingHTTPProtocolVersionNumber;
FOUNDATION_EXPORT const unsigned char JiveAuthenticatingHTTPProtocolVersionString[];

