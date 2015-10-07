//
//  SYComputerModel.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SYComputerStatus_Unknown,
    SYComputerStatus_Waiting,
    SYComputerStatus_Opened,
    SYComputerStatus_Closed,
} SYComputerStatus;

typedef enum : int {
    SYClientSoftware_Transmission,
    SYClientSoftware_uTorrent,
} SYClientSoftware;

@interface SYComputerModel : NSObject <NSCoding>

@property (readonly, strong, atomic) NSString *identifier;
@property (strong, atomic) NSString         *name;
@property (strong, atomic) NSString         *host;
@property (assign, atomic) int              port;
@property (strong, atomic) NSString         *sessionID;
@property (assign, atomic) SYClientSoftware client;

- (instancetype)initWithName:(NSString*)name andHost:(NSString *)host;

- (NSURL *)webURL;
- (NSURL *)apiURL;

- (BOOL)isValid;

+ (int)defaultPortForClient:(SYClientSoftware)client;

@end
