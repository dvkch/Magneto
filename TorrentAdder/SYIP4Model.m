//
//  SYIP4Model.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 01/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYIP4Model.h"

@interface SYIP4Model ()
@property (nonatomic, assign, readwrite) uint32_t decimalValue;
@property (nonatomic, strong, readwrite) NSString *stringValue;
@end

@implementation SYIP4Model

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        self.stringValue = string;

        NSArray *ipExplode = [string componentsSeparatedByString:@"."];
        int seg1 = [ipExplode[0] intValue];
        int seg2 = [ipExplode[1] intValue];
        int seg3 = [ipExplode[2] intValue];
        int seg4 = [ipExplode[3] intValue];
        
        uint32_t intIP = 0;
        intIP |= (uint32_t)((seg1 & 0xFF) << 24);
        intIP |= (uint32_t)((seg2 & 0xFF) << 16);
        intIP |= (uint32_t)((seg3 & 0xFF) << 8);
        intIP |= (uint32_t)((seg4 & 0xFF) << 0);
        
        self.decimalValue = intIP;
    }
    return self;
}

- (instancetype)initWithDecimal:(uint32_t)decimal
{
    self = [super init];
    if (self)
    {
        self.decimalValue = decimal;
        self.stringValue = [NSString stringWithFormat:@"%u.%u.%u.%u",
                            ((self.decimalValue >> 24) & 0xFF),
                            ((self.decimalValue >> 16) & 0xFF),
                            ((self.decimalValue >> 8)  & 0xFF),
                            ((self.decimalValue >> 0)  & 0xFF)];
    }
    return self;
}

- (BOOL)isValidIP
{
    uint32_t low = (self.decimalValue & 0xFF);
    if (low == 0 || low == 255)
        return NO;
    return YES;
}

@end
