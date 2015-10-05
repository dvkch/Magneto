//
//  SYBonjourClient.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 03/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYBonjourClient.h"
#import "NSNetService+SY.h"

NSString * const SYBonjourClientUpdatedDataNotification = @"SYBonjourClientUpdatedDataNotification";

@interface SYBonjourClient () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, strong) NSNetServiceBrowser *browserAFP;
@property (nonatomic, strong) NSNetServiceBrowser *browserSMB;
@property (nonatomic, assign) BOOL started;
@end

@implementation SYBonjourClient

+ (SYBonjourClient *)shared
{
    static dispatch_once_t onceToken;
    static SYBonjourClient *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.services = [NSMutableArray array];
        self.browserAFP = [[NSNetServiceBrowser alloc] init];
        [self.browserAFP setDelegate:self];
        self.browserSMB = [[NSNetServiceBrowser alloc] init];
        [self.browserSMB setDelegate:self];
    }
    return self;
}

- (void)start
{
    if (self.started)
        return;
    
    self.started = YES;
    
    [self.browserSMB searchForServicesOfType:@"_smb._tcp" inDomain:@"local."];
    [self.browserAFP searchForServicesOfType:@"_afpovertcp._tcp" inDomain:@"local."];
    [self.browserSMB scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.browserAFP scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (NSString *)hostnameForIP:(NSString *)ip
{
    NSMutableArray *names = [NSMutableArray array];
    for (NSNetService *service in self.services)
    {
        if ([[service ip4Addresses] containsObject:ip])
        {
            NSString *host = service.hostName;
            host = [host stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", service.domain] withString:@""];
            [names addObject:host];
        }
    }
    
    NSString *shortest = [names firstObject];
    for (NSString *name in names)
        if (name.length < shortest.length)
            shortest = name;
    
    return shortest;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [self.services addObject:service];
    [service setDelegate:self];
    [service resolveWithTimeout:2];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    [self.services removeObject:service];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYBonjourClientUpdatedDataNotification object:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SYBonjourClientUpdatedDataNotification object:nil];
}

@end
