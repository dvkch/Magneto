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
@property (nonatomic, strong) NSMutableArray <NSNetService *> *services;
@property (nonatomic, strong) NSMutableArray <NSNetServiceBrowser *> *browsers;
@property (nonatomic, strong) NSArray <NSString *> *servicesTypes;
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
        self.servicesTypes = @[@"_smb._tcp", @"_afpovertcp._tcp", @"_daap._tcp", @"_home-sharing._tcp", @"_rfb._tcp"];
        self.services = [NSMutableArray array];
        self.browsers = [NSMutableArray array];

        for (NSUInteger i = 0; i < self.servicesTypes.count; ++i)
        {
            NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
            [browser setDelegate:self];
            [self.browsers addObject:browser];
        }
    }
    return self;
}

- (void)start
{
    if (self.started)
        return;
    
    self.started = YES;
    
    for (NSUInteger i = 0; i < self.servicesTypes.count; ++i)
    {
        NSString *serviceType = self.servicesTypes[i];
        NSNetServiceBrowser *browser = self.browsers[i];
        [browser stop];
        [browser searchForServicesOfType:serviceType inDomain:@"local."];
        [browser scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
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
