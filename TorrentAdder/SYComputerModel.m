//
//  SYComputerModel.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYComputerModel.h"
#import "NSHost+SY.h"
// #import "SYBonjourClient.h"

@interface SYComputerModel ()
@property (readwrite, strong, atomic) NSString *identifier;
@end

@implementation SYComputerModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.identifier = [[NSUUID UUID] UUIDString];
        self.sessionID = @"";
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name andHost:(NSString *)host
{
    self = [self init];
    if (self)
    {
        self.name = name;
        self.host = host;
        
        if (!self.name)
            self.name = [NSHost hostWithAddress:self.host].name;
        // TODO: monitor
        
        // if (!self.name)
        // TODO:    self.name = [[SYBonjourClient shared] hostnameForIP:self.host];
        
        if (!self.name)
            self.name = host;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.name       = [aDecoder decodeObjectForKey:@"name"];
        self.host       = [aDecoder decodeObjectForKey:@"host"];
        self.port       = [aDecoder decodeIntForKey:@"port"];
        self.client     = [aDecoder decodeIntForKey:@"client"];
        self.username   = [aDecoder decodeObjectForKey:@"username"];
        self.password   = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier    forKey:@"identifier"];
    [aCoder encodeObject:self.name          forKey:@"name"];
    [aCoder encodeObject:self.host          forKey:@"host"];
    [aCoder encodeInt:self.port             forKey:@"port"];
    [aCoder encodeInt:self.client           forKey:@"client"];
    [aCoder encodeObject:self.username      forKey:@"username"];
    [aCoder encodeObject:self.password      forKey:@"password"];
}

- (BOOL)isEqual:(id)object
{
    if(![object isKindOfClass:[self class]])
        return NO;
    
    return [[(SYComputerModel*)object identifier] isEqualToString:self.identifier];
}

- (NSURL *)baseURL
{
    NSString *url;
    
    /*if (self.password.length)
        url = [NSString stringWithFormat:@"http://%@:%@@%@:%d/", self.username, self.password, self.host, self.port];
    else if (self.username.length)
        url = [NSString stringWithFormat:@"http://%@@%@:%d/", self.username, self.host, self.port];
    else*/
        url = [NSString stringWithFormat:@"http://%@:%d/", self.host, self.port];
    
    return [NSURL URLWithString:url];
}

- (NSURL *)webURL
{
    switch (self.client)
    {
        case SYClientSoftware_Transmission:
            return [NSURL URLWithString:@"transmission/web/" relativeToURL:self.baseURL];
        case SYClientSoftware_uTorrent:
            return [NSURL URLWithString:@"gui/" relativeToURL:self.baseURL];
    }
}

- (NSURL *)apiURL
{
    switch (self.client)
    {
        case SYClientSoftware_Transmission:
            return [NSURL URLWithString:@"transmission/rpc/" relativeToURL:self.baseURL];
        case SYClientSoftware_uTorrent:
            return [NSURL URLWithString:@"gui/" relativeToURL:self.baseURL];
    }
}

- (BOOL)isValid
{
    BOOL authOK = YES;
    
    if (self.password.length)
        authOK = (self.username.length > 0);
    
    return (self.name.length && self.host.length && self.port != 0 && authOK);
}

+ (int)defaultPortForClient:(SYClientSoftware)client
{
    switch (client) {
        case SYClientSoftware_Transmission:
            return 9091;
        case SYClientSoftware_uTorrent:
            return 18764;
    }
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, name: %@, host: %@:%d, user: %@, %@ password>",
            [self class],
            self,
            self.name,
            self.host,
            self.port,
            self.username,
            self.password.length ? @"with" : @"no"];
}

@end
