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
        self->_connections = [[NSMutableArray alloc] init];
        self->_connectionsData = [[NSMutableDictionary alloc] init];
        self->_connectionsResponses = [[NSMutableDictionary alloc] init];
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
        self->_connections = [[NSMutableArray alloc] init];
        self->_connectionsData = [[NSMutableDictionary alloc] init];
        self->_connectionsResponses = [[NSMutableDictionary alloc] init];
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
-(NSURLRequest*)urlRequestForAddingTorrentFromMagnet:(NSURL *)magnet {
    
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

-(void)addTorrent {
    SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if(!appDelegate.url)
        return;
    
    NSURLRequest *request = [self urlRequestForAddingTorrentFromMagnet:appDelegate.url];
    [self->_connections addObject:[[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:YES]];
}

#pragma mark - NSURLConnectionDelegates methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error while adding torrent"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *k = [[[connection originalRequest] URL] absoluteString];
    [self->_connectionsResponses setObject:response forKey:k];
    
    int code = [(NSHTTPURLResponse*)response statusCode];
    if(code == 409) {
        self.sessionID = [[(NSHTTPURLResponse*)response allHeaderFields]
                          objectForKey:@"X-Transmission-Session-Id"];
        [self addTorrent];
    }
    
    [self->_connections removeObject:connection];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *k = [[[connection originalRequest] URL] absoluteString];
    NSMutableData *d = [self->_connectionsData objectForKey:k];
    if(!d) d = [[NSMutableData alloc] init];
    
    [d appendData:data];
    
    [self->_connectionsData setObject:data forKey:k];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // it is guaranteed to have a response before did finish loading
    // http://stackoverflow.com/questions/7360526/is-didreceiveresponse-guaranteed-to-preceed-connectiondidfinishloading
    
    NSString *k = [[[connection originalRequest] URL] absoluteString];
    NSURLResponse *r = [self->_connectionsResponses objectForKey:k];
    int code = [(NSHTTPURLResponse*)r statusCode];
    
    if(code == 409)
        return;
    
    NSMutableData *d = [self->_connectionsData objectForKey:k];
    NSString     *bodyString = [d stringWithUTF8Encoding];
    NSDictionary *bodyJSON   = [d json];
    
    if(code == 200) {
        NSString *message = @"";
        
        if(bodyJSON)
            message = [NSString stringWithFormat:@"Message from %@: %@",
                       self.name,
                       bodyJSON[@"result"]];
        
        [[[UIAlertView alloc] initWithTitle:@"Torrent added successfully"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];

        SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if(appDelegate.appUrlIsFromParsed != SYAppUnknown) {
            [appDelegate openAppThatOpenedMe];
        }

    }
    else {
        NSString *message = [NSString stringWithFormat:@"Message from %@: \n%@",
                             self.name,
                             bodyString];
        
        [[[UIAlertView alloc] initWithTitle:@"Unknown response"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];
    }
}

-(BOOL)hasHostnameAndIP
{
    return  self.name &&
            [self.name length] &&
            self.firstIP4address &&
            [self.firstIP4address length];
}


@end
