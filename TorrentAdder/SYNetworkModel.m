//
//  SYNetworkModel.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYNetworkModel.h"
#import "SYIP4Model.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation SYNetworkModel

- (NSArray *)allIPsOnNetwork:(BOOL)ignoreMyIP
{
    if (!self.ipAddress || !self.submask)
        return nil;
    
    NSMutableArray *ips = [NSMutableArray array];
    
    uint32_t decimalIP   = [[[SYIP4Model alloc] initWithString:self.ipAddress] decimalValue];
    uint32_t decimalMask = [[[SYIP4Model alloc] initWithString:self.submask]   decimalValue];
    
    uint32_t firstIP =  decimalMask & decimalIP;
    uint32_t count   = ~decimalMask;
    
    for (uint32_t ip = firstIP; ip < firstIP + count; ++ip)
    {
        if (ignoreMyIP && decimalIP == ip)
            continue;
        
        SYIP4Model *modelIP = [[SYIP4Model alloc] initWithDecimal:ip];
        if ([modelIP isValidIP])
            [ips addObject:[modelIP stringValue]];
    }
    
    return [ips copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, if: %@, ip: %@, mask: %@>",
            [self class],
            self,
            self.interfaceName,
            self.ipAddress,
            self.submask];
}


+ (NSArray<SYNetworkModel *> *)myNetworks:(BOOL)onlyLocalEnXinterfaces
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
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                SYNetworkModel *network = [[SYNetworkModel alloc] init];
                network.interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                
                if (onlyLocalEnXinterfaces && ![network.interfaceName hasPrefix:@"en"]) {
                    temp_addr = temp_addr->ifa_next;
                    continue;
                }

                network.ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                network.submask   = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                
                if (onlyLocalEnXinterfaces && ![network.submask isEqualToString:@"255.255.255.0"]) {
                    temp_addr = temp_addr->ifa_next;
                    continue;
                }
                
                [networks addObject:network];
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return [networks copy];;
}

@end
