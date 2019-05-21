//
//  SYHost.h
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHost : NSObject
+ (void)flushHostCache;
+ (void)setHostCacheEnabled:(BOOL)arg1;
+ (BOOL)isHostCacheEnabled;
+ (nullable NSHost *)hostWithAddress:(_Nullable id)arg1;
+ (nullable NSHost *)hostWithName:(_Nullable id)arg1;
+ (nullable NSHost *)currentHost;
- (nullable NSString *)localizedName;
- (nullable NSArray <NSString *> *)names;
- (nullable NSString *)name;
@end
