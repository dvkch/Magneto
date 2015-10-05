//
//  SYBonjourClient.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 03/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SYBonjourClientUpdatedDataNotification;

@interface SYBonjourClient : NSObject

+ (SYBonjourClient *)shared;

- (void)start;

- (NSString *)hostnameForIP:(NSString *)ip;

@end
