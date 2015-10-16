//
//  SYPinger.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYPinger.h"
#import "SYNetworkModel.h"
#import "SPLPing.h"

@interface SYPing : SPLPing
@property (nonatomic, assign) NSUInteger countFailed;
@property (nonatomic, assign) NSUInteger countSuccess;
- (void)updateWithResponse:(SPLPingResponse *)response;
@end

@implementation SYPing
- (void)updateWithResponse:(SPLPingResponse *)response
{
    if (response.error)
        ++self.countFailed;
    else
        ++self.countSuccess;
}
@end

@interface SYPinger ()
@property (nonatomic, strong) NSArray<SYNetworkModel *> *networks;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, strong) NSMutableArray *queuedIPs;
@property (nonatomic, strong) NSMutableSet *runningIPs;
@property (nonatomic, strong) NSMutableSet *endedIPs;
@property (nonatomic, strong) NSMutableSet *validIPs;
@property (nonatomic, strong) NSMutableArray *pingers;
@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);
@property (nonatomic, copy) void(^validIpFoundBlock)(NSString *ip);
@property (nonatomic, copy) void(^finishedBlock)(BOOL finished);
@end

@implementation SYPinger

+ (SYPinger *)pingerWithNetworks:(NSArray <SYNetworkModel *> *)networks
{
    SYPinger *pinger = [[self alloc] init];
    [pinger setNetworks:networks];
    return pinger;
}

- (void)pingNetworkWithProgressBlock:(void (^)(CGFloat))progressBlock
                   validIpFoundBlock:(void (^)(NSString *))validIpFoundBlock
                       finishedBlock:(void (^)(BOOL))finishedBlock
{
    if (self.queuedIPs || !self.networks.count)
        return;
    
    self.progressBlock      = progressBlock;
    self.validIpFoundBlock  = validIpFoundBlock;
    self.finishedBlock      = finishedBlock;
    
    self.queuedIPs  = [NSMutableArray array];
    self.runningIPs = [NSMutableSet set];
    self.endedIPs   = [NSMutableSet set];
    self.validIPs   = [NSMutableSet set];
    self.pingers    = [NSMutableArray array];
    
    for (SYNetworkModel *network in self.networks)
    {
        [self.queuedIPs addObjectsFromArray:[network allIPsOnNetwork:NO]];
    }
    
    self.totalCount = self.queuedIPs.count;
    [self executeQueue];
}

- (void)stop
{
    self.canceled = YES;
    if (self.finishedBlock)
        self.finishedBlock(NO);
}

- (void)executeQueue
{
    if (!self.queuedIPs.count || self.canceled)
        return;
    
    while (self.runningIPs.count < 64)
    {
        NSString *ip = [self.queuedIPs firstObject];
        [self.queuedIPs removeObject:ip];
        [self.runningIPs addObject:ip];
        
        SPLPingConfiguration *config = [[SPLPingConfiguration alloc] initWithPingInterval:0.1 timeoutInterval:1];
        SYPing *ping = [[SYPing alloc] initWithIPv4Address:ip configuration:config];
        [self.pingers addObject:ping];
        
        [ping setObserver:^(SPLPing * _Nonnull p, SPLPingResponse * _Nonnull r) {
            SYPing *pp = (SYPing *)p;
            [pp updateWithResponse:r];
            if (pp.countSuccess + pp.countFailed > 3)
            {
                [pp setObserver:nil];
                [pp stop];
                [self ip:ip finishedWithSuccess:(pp.countSuccess > 0)];
            }
        }];
        
        [ping start];
    }
}

- (void)ip:(NSString *)ip finishedWithSuccess:(BOOL)success
{
    [self.runningIPs removeObject:ip];
    [self.endedIPs addObject:ip];
    
    if (success)
    {
        [self.validIPs addObject:ip];
        if (self.validIpFoundBlock)
            self.validIpFoundBlock(ip);
    }
    
    [self executeQueue];

    if (self.progressBlock)
        self.progressBlock((CGFloat)self.endedIPs.count / (CGFloat)(self.totalCount));
    
    if (self.endedIPs.count == self.totalCount && self.finishedBlock)
        self.finishedBlock(YES);
}

@end
