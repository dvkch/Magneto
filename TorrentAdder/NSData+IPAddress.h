//
//  NSData+IPAddress.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (IPAddress)

-(NSString *)ipAddressStringFromData:(BOOL)onlyIPv4;

@end
