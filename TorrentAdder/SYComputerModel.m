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

@interface SYComputerModel (Private)
-(void)isPortOpened:(NSNumber*)port success:(void(^)(BOOL))successBlock;
-(void)refreshPortOpened;
@end

@implementation SYComputerModel

-(id)init {
    self = [super init];
    if(self) {
        self.name = @"Unknown";
        self.ip4s = @[];
        self.transmissionPort = @(9091);
        self.uTorrentPort = @(18764);
        self.sessionID = @"";
        self->_transmissionPortOpened = PortResult_Waiting;
        self->_uTorrentPortOpened = PortResult_Waiting;
    }
    return self;
}

-(id)initWithName:(NSString *)name andIPs:(NSArray *)ip4s {
    self = [self init];
    if(self) {
        self.name = name;
        self.ip4s = ip4s;
        [self refreshPortOpened];
    }
    return self;
}

-(id)initWithService:(NSNetService *)service {
    self = [self init];
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
        [self refreshPortOpened];
    }
    return self;
}

-(void)refreshPortOpened {
    self->_uTorrentPortOpened = PortResult_Waiting;
    [self uTorrentPortOpened:^(BOOL opened) {
        self->_uTorrentPortOpened = opened ? PortResult_Opened : PortResult_Closed;
    }];
    
    self->_transmissionPortOpened = PortResult_Waiting;
    [self transmissionPortOpened:^(BOOL opened) {
        self->_transmissionPortOpened = opened ? PortResult_Opened : PortResult_Closed;
    }];
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

-(void)isPortOpened:(NSNumber*)port success:(void(^)(BOOL))successBlock
{
    if(!self.firstIP4address) {
        if(successBlock)
            successBlock(NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int s = socket(PF_INET, SOCK_STREAM, 0); // 0 = IP
        
        struct sockaddr_in ipAddress;
        ipAddress.sin_len = sizeof(ipAddress);
        ipAddress.sin_family = AF_INET;
        ipAddress.sin_port = htons(port.intValue);
        inet_pton(AF_INET,
                  [self.firstIP4address cStringUsingEncoding:NSASCIIStringEncoding],
                  &ipAddress.sin_addr);
        
        int c = connect(s, (struct sockaddr *)&ipAddress, ipAddress.sin_len);
        if(c == 0) close(s);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(successBlock)
                successBlock(c == 0);
        });
    });
}

-(void)transmissionPortOpened:(void (^)(BOOL opened))successBlock {
    self->_transmissionPortOpened = PortResult_Waiting;
    
    [self isPortOpened:self.transmissionPort success:^(BOOL opened) {
        self->_transmissionPortOpened = opened ? PortResult_Opened : PortResult_Closed;
        if(successBlock)
            successBlock(opened);
    }];
}

-(void)uTorrentPortOpened:(void (^)(BOOL opened))successBlock {
    self->_uTorrentPortOpened = PortResult_Waiting;
    
    [self isPortOpened:self.uTorrentPort success:^(BOOL opened) {
        self->_uTorrentPortOpened = opened ? PortResult_Opened : PortResult_Closed;
        if(successBlock)
            successBlock(opened);
    }];
}

-(void)atLeastOnePortOpened:(void (^)(BOOL opened))successBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        __block PortResult transmission = PortResult_Closed;
        __block PortResult utorrent     = PortResult_Closed;
        
        [self uTorrentPortOpened:^(BOOL opened) {
            utorrent = (opened ? PortResult_Opened : PortResult_Closed);
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        [self transmissionPortOpened:^(BOOL opened) {
            transmission = (opened ? PortResult_Opened : PortResult_Closed);
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(successBlock)
                successBlock(transmission == PortResult_Opened || transmission == PortResult_Opened);
        });
    });
}

-(NSURL *)transmissionApiURL {
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/transmission/rpc",
                           self.firstIP4address,
                           self.transmissionPort.intValue];
    
    return [NSURL URLWithString:urlString];
}

-(NSURL *)transmissionGuiURL {
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/transmission/web/",
                           self.firstIP4address,
                           self.transmissionPort.intValue];
    
    return [NSURL URLWithString:urlString];
}

-(NSURL *)uTorrentApiURL {
    return nil;
}

-(NSURL *)uTorrentGuiURL {
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/gui",
                           self.firstIP4address,
                           self.uTorrentPort.intValue];
    
    return [NSURL URLWithString:urlString];
}

// https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
-(NSURLRequest*)requestForAddingMagnetTransmission:(NSURL *)magnet {
    
    if(!magnet)
        return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.transmissionApiURL];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *d = @{@"method"    : @"torrent-add",
                        @"arguments" : @{@"filename":[magnet absoluteString]}};
    
    NSString *post = [d bv_jsonStringWithPrettyPrint:NO];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:self.sessionID forHTTPHeaderField:@"X-Transmission-Session-Id"];
    [request setHTTPBody:postData];
    
    return request;
}

-(NSURLRequest*)requestForAddingMagnetUTorrent:(NSURL*)magnet {
    NSLog(@"NOT IMPLEMENTED");
    return nil;
}

-(BOOL)hasHostnameAndIP
{
    return  self.name &&
            [self.name length] &&
            self.firstIP4address &&
            [self.firstIP4address length];
}


@end
