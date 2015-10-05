
//
//  NSObject+SY.m
//  TorrentAdder
//
//  Created by syan on 9/28/15.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSObject+SY.h"

@implementation NSObject (SY)

- (NSString *)parsedString
{
    if ([self isKindOfClass:[NSNull class]])
        return nil;
    if ([self isKindOfClass:[NSNumber class]])
        return [(NSNumber *)self stringValue];
    return [self description];
}

+ (NSString *)className
{
    return [[self class] description];
}

@end
