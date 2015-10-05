//
//  NSNetService+SY.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 03/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSNetService+SY.h"
#import <arpa/inet.h>

@implementation NSNetService (SY)

- (NSArray<NSString *> *)ip4Addresses
{
    NSMutableArray *addresses = [NSMutableArray array];
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in self.addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && socketAddress->sa.sa_family == AF_INET)
        {
            const char *addressStr = inet_ntop(socketAddress->sa.sa_family,
                                               (void *)&(socketAddress->ipv4.sin_addr),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            //int port = ntohs(socketAddress->ipv4.sin_port);
            [addresses addObject:[NSString stringWithCString:addressStr encoding:NSUTF8StringEncoding]];
        }
    }
    
    return [addresses copy];
}

@end
