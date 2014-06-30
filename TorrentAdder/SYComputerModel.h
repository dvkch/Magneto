//
//  SYComputerModel.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PortResult_Waiting,
    PortResult_Opened,
    PortResult_Closed,
} PortResult;

@interface SYComputerModel : NSObject

@property (strong, atomic) NSString *name;
@property (strong, atomic) NSArray  *ip4s;
@property (strong, atomic) NSNumber *uTorrentPort;
@property (strong, atomic) NSNumber *transmissionPort;
@property (strong, atomic) NSString *sessionID;
@property (readonly) PortResult transmissionPortOpened;
@property (readonly) PortResult uTorrentPortOpened;

-(id)initWithName:(NSString*)name andIPs:(NSArray*)ip4s;
-(id)initWithService:(NSNetService*)service;

-(NSString*)firstIP4address;
-(void)transmissionPortOpened:(void(^)(BOOL opened))successBlock;
-(void)uTorrentPortOpened:(void(^)(BOOL opened))successBlock;
-(void)atLeastOnePortOpened:(void(^)(BOOL opened))successBlock;

-(NSURL*)transmissionApiURL;
-(NSURL*)transmissionGuiURL;

-(NSURL*)uTorrentApiURL;
-(NSURL*)uTorrentGuiURL;

-(NSURLRequest*)requestForAddingMagnetTransmission:(NSURL*)magnet;
-(NSURLRequest*)requestForAddingMagnetUTorrent:(NSURL*)magnet;

-(BOOL)hasHostnameAndIP;

@end
