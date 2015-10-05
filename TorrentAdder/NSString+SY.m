//
//  NSString+SY.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "NSString+SY.h"

@implementation NSString (SY)

- (BOOL)isEqualToStringNoCase:(NSString*)string
{
    return [self compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (NSString *)stringWithLimit:(NSUInteger)limit
{
    if (self.length < limit)
        return self;
    
    return [self substringToIndex:limit];
}

@end
