//
//  NSURLRequest+SY.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 13/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (SY)

@property (nonatomic, strong) NSString *computerID;
@property (nonatomic, assign) BOOL isIsUpRequest;
@property (nonatomic, assign) NSInteger numberOfAuthTries;

@end
