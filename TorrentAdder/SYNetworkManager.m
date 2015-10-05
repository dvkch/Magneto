//
//  SYNetworkManager.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYNetworkManager.h"
#import <CocoaAsyncSocket.h>
#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <err.h>
#import <sys/types.h>
#import <sys/socket.h>
#import "SYNetworkModel.h"

@interface NSHost : NSObject
+ (void)flushHostCache;
+ (void)setHostCacheEnabled:(BOOL)arg1;
+ (BOOL)isHostCacheEnabled;
+ (id)hostWithAddress:(id)arg1;
+ (id)hostWithName:(id)arg1;
+ (id)currentHost;
- (id)localizedName;
- (id)names;
- (id)name;
@end

@interface SYNetworkManager () <GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) NSMutableArray *waitingComputers;
@property (nonatomic, strong) NSMutableArray *openedComputers;
@property (nonatomic, strong) NSMutableArray *closedComputers;
@end

@implementation SYNetworkManager

+ (SYNetworkManager *)shared
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)startStatusUpdateForComputer:(SYComputerModel *)computer
{
    // refresh!
}

- (SYComputerStatus)statusForComputer:(SYComputerModel *)computer
{
    if ([self.waitingComputers containsObject:computer])
        return SYComputerStatus_Waiting;
    if ([self.openedComputers containsObject:computer])
        return SYComputerStatus_Opened;
    if ([self.closedComputers containsObject:computer])
        return SYComputerStatus_Closed;
    [self startStatusUpdateForComputer:computer];
    return SYComputerStatus_Unknown;
}

+ (NSArray<SYNetworkModel *> *)myNetworks:(BOOL)onlyEnXinterfaces
{
    NSMutableArray *networks = [NSMutableArray array];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                SYNetworkModel *network = [[SYNetworkModel alloc] init];
                network.interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if (!onlyEnXinterfaces || [network.interfaceName hasPrefix:@"en"])
                {
                    network.ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    network.submask   = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    [networks addObject:network];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return [networks copy];;
}

+ (NSString *)hostnameForIP:(NSString *)hostIP
{
    return [[NSHost hostWithAddress:hostIP] name];
}

@end
