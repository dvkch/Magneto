//
//  NSCalendar+SY.h
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/04/2017.
//  Copyright © 2017 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (SY)

- (NSDate *)sy_dateWithDay:(NSDate *)day andTime:(NSDate *)time;
- (NSDate *)sy_dateWithYear:(NSDate *)year dayAndTime:(NSDate *)dayAndTime;

@end
