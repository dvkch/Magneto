//
//  SYNetworkManager.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYComputerModel.h"

@class SYNetworkManager;
@class SYComputerModel;
@class SYNetworkModel;

extern NSString * const SYNetworkManagerComputerStatusChangedNotification;

@protocol SYNetworkManagerDelegate <NSObject>
- (void)networkManager:(SYNetworkManager *)networkManager changedStatusForComputer:(SYComputerModel *)computer;
@end

@interface SYNetworkManager : NSObject

@property (nonatomic, weak) id <SYNetworkManagerDelegate> delegate;

+ (SYNetworkManager *)shared;

- (void)startStatusUpdateForComputer:(SYComputerModel *)computer;

- (SYComputerStatus)statusForComputer:(SYComputerModel *)computer;
- (SYComputerStatus)previousStatusForComputer:(SYComputerModel *)computer;

+ (NSArray <SYNetworkModel *> *)myNetworks:(BOOL)onlyEnXinterfaces;

+ (NSString *)hostnameForIP:(NSString *)ip;

@end
