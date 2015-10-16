//
//  SYNetworkManager.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYNetworkManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "SYNetworkModel.h"
#import "NSURLRequest+SY.h"

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

NSString * const SYNetworkManagerComputerStatusChangedNotification = @"SYNetworkManagerComputerStatusChangedNotification";

@interface SYNetworkManager ()
@property (nonatomic, strong) NSMutableDictionary *statuses;
@property (nonatomic, strong) NSMutableDictionary *previousStatuses;
@property (nonatomic, strong) NSMutableDictionary *times;
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
        self.statuses           = [NSMutableDictionary dictionary];
        self.previousStatuses   = [NSMutableDictionary dictionary];
        self.times              = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)startStatusUpdateForComputer:(SYComputerModel *)computer
{
    if ([[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startStatusUpdateForComputer:computer];
        });
        return;
    }
    
    [self setStatus:SYComputerStatus_Waiting forComputer:computer];
    
    NSURLResponse *response;
    NSError *error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:computer.webURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:4];
    [request setComputerID:computer.identifier];
    [request setIsIsUpRequest:YES];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"%@ - %@ - %@\n\n\n", computer.name, response, error);
        if (error)
            [self setStatus:SYComputerStatus_Closed forComputer:computer];
        else
            [self setStatus:SYComputerStatus_Opened forComputer:computer];
    });
}

- (void)setStatus:(SYComputerStatus)status forComputer:(SYComputerModel *)computer
{
    if (![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStatus:status forComputer:computer];
        });
        return;
    }
    
    [self.times setObject:[NSDate date] forKey:computer.identifier];
    
    if (status == [self statusForComputer:computer])
        return;
    
    [self.previousStatuses setObject:@([self statusForComputer:computer]) forKey:computer.identifier];
    [self.statuses setObject:@(status) forKey:computer.identifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNetworkManagerComputerStatusChangedNotification object:computer];
    
    if ([self.delegate respondsToSelector:@selector(networkManager:changedStatusForComputer:)])
        [self.delegate networkManager:self changedStatusForComputer:computer];
}

- (SYComputerStatus)statusForComputer:(SYComputerModel *)computer
{
    if (![[NSThread currentThread] isMainThread])
    {
        __block SYComputerStatus status;
        dispatch_sync(dispatch_get_main_queue(), ^{
            status = [self statusForComputer:computer];
        });
        return status;
    }
    
    SYComputerStatus status = [[self.statuses objectForKey:computer.identifier] unsignedIntegerValue];
    
    NSDate *lastUpdateDate = self.times[computer.identifier];
    BOOL startUpdate = !lastUpdateDate || [lastUpdateDate timeIntervalSinceNow] < -10;
    
    if (startUpdate && status != SYComputerStatus_Waiting)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startStatusUpdateForComputer:computer];
        });
    }
    
    return status;
}

- (SYComputerStatus)previousStatusForComputer:(SYComputerModel *)computer
{
    if (![[NSThread currentThread] isMainThread])
    {
        __block SYComputerStatus status;
        dispatch_sync(dispatch_get_main_queue(), ^{
            status = [self previousStatusForComputer:computer];
        });
        return status;
    }
    
    return [[self.previousStatuses objectForKey:computer.identifier] unsignedIntegerValue];
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
