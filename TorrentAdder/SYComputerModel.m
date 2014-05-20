//
//  SYComputerModel.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYComputerModel.h"
#import "NSData+IPAddress.h"
#import "NSArray+JSON.h"
#import "SYAppDelegate.h"

#include <arpa/inet.h>
#include <sys/socket.h>

@implementation SYComputerModel

-(id)init {
    self = [self initWithName:@"Unknown" andIPs:nil];
    return self;
}

-(id)initWithName:(NSString *)name andIPs:(NSArray *)ip4s {
    self = [super init];
    if(self) {
        self.name = name;
        self.ip4s = ip4s;
        self.port = [NSNumber numberWithInt:9091];
        self.sessionID = @"";
    }
    return self;
}

-(id)initWithService:(NSNetService *)service {
    self = [super init];
    if(self) {
        NSMutableArray *arr = [@[] mutableCopy];
        for(NSData *ipData in [service addresses]) {
            NSString *ip = [ipData ipAddressStringFromData:YES];
            if(ip)
                [arr addObject:ip];
        }
        self.ip4s = [NSArray arrayWithArray:arr];
        self.name = [[service hostName] stringByReplacingOccurrencesOfString:@".local."
                                                                  withString:@""];
        self.port = [NSNumber numberWithInt:9091];
        self.sessionID = @"";
    }
    return self;
}

-(NSString*)firstIP4address {
    if([self.ip4s count] == 0)
        return nil;
    return [self.ip4s objectAtIndex:0];
}

-(BOOL)isEqual:(id)object {
    if(![object isKindOfClass:[self class]])
        return NO;
    
    return [[(SYComputerModel*)object name] isEqualToString:self.name];
}

-(BOOL)isPortOpened {
    if(!self.firstIP4address)
        return NO;
    
    int s = socket(PF_INET, SOCK_STREAM, 0); // 0 = IP
    
    struct sockaddr_in ipAddress;
    ipAddress.sin_len = sizeof(ipAddress);
    ipAddress.sin_family = AF_INET;
    ipAddress.sin_port = htons(self.port.intValue);
    inet_pton(AF_INET,
              [self.firstIP4address cStringUsingEncoding:NSASCIIStringEncoding],
              &ipAddress.sin_addr);
    
    int c = connect(s, (struct sockaddr *)&ipAddress, ipAddress.sin_len);
    if(c == 0) close(s);
    
    return (c == 0);
}

-(NSURL *)rpcURL {
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/transmission/rpc",
                           self.firstIP4address,
                           self.port.intValue];
    
    return [NSURL URLWithString:urlString];
}

// https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
-(NSURLRequest*)requestForAddingMagnet:(NSURL *)magnet {
    
    if(!magnet)
        return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.rpcURL];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *d = @{@"method"    : @"torrent-add",
                        @"arguments" : @{@"filename":[magnet absoluteString]}};
    
    NSString *post = [d bv_jsonStringWithPrettyPrint:NO];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:self.sessionID forHTTPHeaderField:@"X-Transmission-Session-Id"];
    [request setHTTPBody:postData];
    
    return request;
}


-(BOOL)hasHostnameAndIP
{
    return  self.name &&
            [self.name length] &&
            self.firstIP4address &&
            [self.firstIP4address length];
}


@end
