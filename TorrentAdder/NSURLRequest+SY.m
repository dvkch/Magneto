//
//  NSURLRequest+SY.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 13/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSURLRequest+SY.h"

@implementation NSMutableURLRequest (SY)

- (NSString *)computerID
{
    return self.allHTTPHeaderFields[@"Z-MyComputerID"];
}

- (void)setComputerID:(NSString *)computerID
{
    [self setValue:computerID forHTTPHeaderField:@"Z-MyComputerID"];
}

- (BOOL)isIsUpRequest
{
    return [(NSString *)self.allHTTPHeaderFields[@"Z-IsUpRequest"] boolValue];
}

- (void)setIsIsUpRequest:(BOOL)isIsUpRequest
{
    [self setValue:[@(isIsUpRequest) stringValue] forHTTPHeaderField:@"Z-IsUpRequest"];
}

- (NSInteger)numberOfAuthTries
{
    return [(NSString *)self.allHTTPHeaderFields[@"Z-NumberOfAuthTries"] integerValue];
}

- (void)setNumberOfAuthTries:(NSInteger)numberOfAuthTries
{
    [self setValue:[@(numberOfAuthTries) stringValue] forHTTPHeaderField:@"Z-NumberOfAuthTries"];
}

@end
