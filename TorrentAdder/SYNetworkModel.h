//
//  SYNetworkModel.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNetworkModel : NSObject

@property (nonatomic, strong) NSString *interfaceName;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, strong) NSString *submask;

- (nonnull NSArray <NSString *> *)allIPsOnNetwork:(BOOL)ignoreMyIP;

+ (nonnull NSArray<SYNetworkModel *> *)myNetworks:(BOOL)onlyLocalEnXinterfaces;

@end
