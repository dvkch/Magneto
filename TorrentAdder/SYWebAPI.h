//
//  SYWebAPI.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 23/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYResultModel.h"

@interface SYWebAPI : NSObject

@property (class, readonly) SYWebAPI *shared;

- (void)findMirrorWithCompletionBlock:(void(^)(NSError *error))block;

- (void)lookFor:(NSString *)term
     completion:(void(^)(NSArray<SYResultModel *> *items, NSError *error))block;

- (void)getMagnetForResult:(SYResultModel *)result
                completion:(void(^)(NSString *magnet, NSError *error))block;

@end
