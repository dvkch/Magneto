//
//  SYPinger.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNetworkModel;

@interface SYPinger : NSObject

+ (SYPinger *)pingerWithNetworks:(NSArray <SYNetworkModel *> *)networks;

- (void)pingNetworkWithProgressBlock:(void(^)(CGFloat progress))progressBlock
                   validIpFoundBlock:(void(^)(NSString *ip))validIpFoundBlock
                       finishedBlock:(void(^)(BOOL finished))finishedBlock;

- (void)stop;

@end
