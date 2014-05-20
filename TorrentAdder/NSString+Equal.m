//
//  NSString+Equal.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "NSString+Equal.h"

@implementation NSString (Equal)

-(BOOL)isEqualToStringNoCase:(NSString*)string
{
    return [self compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

@end
