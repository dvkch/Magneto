//
//  SYIP4Model.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYIP4Model : NSObject

@property (nonatomic, assign, readonly) uint32_t decimalValue;
@property (nonatomic, strong, readonly) NSString *stringValue;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithDecimal:(uint32_t)decimal;

- (BOOL)isValidIP;

@end
