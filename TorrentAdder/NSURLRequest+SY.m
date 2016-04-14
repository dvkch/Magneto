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
    return [NSURLProtocol propertyForKey:@"sy_computer_id" inRequest:self];
}

- (void)setComputerID:(NSString *)computerID
{
    [NSURLProtocol setProperty:computerID forKey:@"sy_computer_id" inRequest:self];
}

- (BOOL)isIsUpRequest
{
    return [[NSURLProtocol propertyForKey:@"sy_request_is_up" inRequest:self] boolValue];
}

- (void)setIsIsUpRequest:(BOOL)isIsUpRequest
{
    [NSURLProtocol setProperty:@(isIsUpRequest) forKey:@"sy_request_is_up" inRequest:self];
}

- (NSInteger)numberOfAuthTries
{
    return [[NSURLProtocol propertyForKey:@"sy_number_of_auth_tries" inRequest:self] integerValue];
}

- (void)setNumberOfAuthTries:(NSInteger)numberOfAuthTries
{
    [NSURLProtocol setProperty:@(numberOfAuthTries) forKey:@"sy_number_of_auth_tries" inRequest:self];
}

@end
