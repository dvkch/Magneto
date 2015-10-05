//
//  SYNetworkModel.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYNetworkModel.h"
#import "SYIP4Model.h"

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

@end
