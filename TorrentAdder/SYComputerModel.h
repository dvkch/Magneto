//
//  SYComputerModel.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYComputerModel : NSObject

@property (strong, atomic) NSString *name;
@property (strong, atomic) NSArray  *ip4s;
@property (strong, atomic) NSNumber *portuTorrent;
@property (strong, atomic) NSNumber *portTransmission;
@property (strong, atomic) NSString *sessionID;

-(id)initWithName:(NSString*)name andIPs:(NSArray*)ip4s;
-(id)initWithService:(NSNetService*)service;

-(NSString*)firstIP4address;
-(BOOL)transmissionPortOpened;
-(BOOL)uTorrentPortOpened;

-(NSURL*)transmissionApiURL;
-(NSURL*)transmissionGuiURL;

-(NSURL*)uTorrentApiURL;
-(NSURL*)uTorrentGuiURL;

-(NSURLRequest*)requestForAddingMagnetTransmission:(NSURL*)magnet;
-(NSURLRequest*)requestForAddingMagnetUTorrent:(NSURL*)magnet;

-(BOOL)hasHostnameAndIP;

@end
