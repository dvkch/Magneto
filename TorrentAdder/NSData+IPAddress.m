//
//  NSData+IPAddress.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "NSData+IPAddress.h"
#include <arpa/inet.h>

@implementation NSData (IPAddress)

// http://stackoverflow.com/questions/938521/iphone-bonjour-nsnetservice-ip-address-and-port

-(NSString *)ipAddressStringFromData:(BOOL)onlyIPv4 {
    
    NSString *addressString = nil;
    //int port = -1;
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    memset(addressBuffer, 0, INET6_ADDRSTRLEN);
    
    typedef union {
        struct sockaddr sa;
        struct sockaddr_in ipv4;
        struct sockaddr_in6 ipv6;
    } ip_socket_address;
    
    ip_socket_address *socketAddress = (ip_socket_address *)[self bytes];
    
    if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6))
    {
        
        if(socketAddress->sa.sa_family == AF_INET6 && onlyIPv4)
            return nil;
        
        const char *addressStr = inet_ntop(socketAddress->sa.sa_family,
                                           (socketAddress->sa.sa_family == AF_INET ?
                                            (void *)&(socketAddress->ipv4.sin_addr) :
                                            (void *)&(socketAddress->ipv6.sin6_addr)),
                                           addressBuffer,
                                           sizeof(addressBuffer));
        
        addressString = [NSString stringWithCString:addressStr encoding:NSASCIIStringEncoding];
        /*
        port = ntohs(socketAddress->sa.sa_family == AF_INET ?
                     socketAddress->ipv4.sin_port :
                     socketAddress->ipv6.sin6_port);
        */
    }
    
    return addressString;
}



@end
