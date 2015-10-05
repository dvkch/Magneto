//
//  NSString+SY.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SY)

- (BOOL)isEqualToStringNoCase:(NSString*)string;
- (NSString *)stringWithLimit:(NSUInteger)limit;

@end
