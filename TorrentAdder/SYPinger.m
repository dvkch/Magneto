//
//  SYPinger.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYPinger.h"
#import "SYNetworkModel.h"
#import "GBPing.h"

@interface SYPing : GBPing
@property (nonatomic, assign) NSUInteger countFailed;
@property (nonatomic, assign) NSUInteger countSuccesses;
@end
@implementation SYPing
@end

@interface SYPinger () <GBPingDelegate>
@property (nonatomic, strong) NSArray<SYNetworkModel *> *networks;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, strong) NSMutableArray *queuedIPs;
@property (nonatomic, strong) NSMutableSet *runningIPs;
@property (nonatomic, strong) NSMutableSet *endedIPs;
@property (nonatomic, strong) NSMutableSet *validIPs;
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
    
#warning change lib
    while (self.runningIPs.count < 10)
    {
        NSString *ip = [self.queuedIPs firstObject];
        [self.queuedIPs removeObject:ip];
        [self.runningIPs addObject:ip];
        
        SYPing *ping = [[SYPing alloc] init];
        [ping setHost:ip];
        [ping setDelegate:self];
        [ping setupWithBlock:^(BOOL success, NSError *error) {
            if (error)
            {
                [self ip:ip finishedWithSuccess:NO];
            }
            else
            {
                [ping startPinging];
            }
        }];
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

- (void)dealWithPing:(SYPing *)pinger
{
    if (self.canceled)
    {
        [pinger setDelegate:nil];
        [pinger stop];
        return;
    }
    
    if (pinger.countSuccesses + pinger.countFailed < 2)
        return;
    
    [pinger setDelegate:nil];
    [pinger stop];
    [self ip:pinger.host finishedWithSuccess:(pinger.countSuccesses > 0)];
}

- (void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary
{
    ((SYPing *)pinger).countSuccesses += 1;
    [self dealWithPing:(SYPing *)pinger];
}

-(void)ping:(GBPing *)pinger didFailWithError:(NSError *)error
{
    ((SYPing *)pinger).countFailed += 1;
    [self dealWithPing:(SYPing *)pinger];
}

-(void)ping:(GBPing *)pinger didFailToSendPingWithSummary:(GBPingSummary *)summary error:(NSError *)error
{
    ((SYPing *)pinger).countFailed += 1;
    [self dealWithPing:(SYPing *)pinger];
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary
{
    ((SYPing *)pinger).countFailed += 1;
    [self dealWithPing:(SYPing *)pinger];
}

-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary
{
    ((SYPing *)pinger).countFailed += 1;
    [self dealWithPing:(SYPing *)pinger];
}

@end
