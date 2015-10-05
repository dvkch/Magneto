//
//  SYClientAPI.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYComputerModel;

@interface SYClientAPI : NSObject

+ (SYClientAPI *)shared;

- (void)addMagnet:(NSURL *)magnet
       toComputer:(SYComputerModel *)computer
       completion:(void(^)(NSString *message, NSError *error))block;

@end
