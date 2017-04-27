//
//  NSCalendar+SY.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/04/2017.
//  Copyright © 2017 Syan. All rights reserved.
//

#import "NSCalendar+SY.h"

@implementation NSCalendar (SY)

- (NSDate *)sy_dateWithDay:(NSDate *)day andTime:(NSDate *)time
{
    if (!time || !day)
        return nil;
    
    NSDateComponents *componentsTime = [self components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:time];
    NSDateComponents *componentsDate = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:day];
    [componentsDate setHour:componentsTime.hour];
    [componentsDate setMinute:componentsTime.minute];
    return [self dateFromComponents:componentsDate];
}

- (NSDate *)sy_dateWithYear:(NSDate *)year dayAndTime:(NSDate *)dayAndTime
{
    if (!dayAndTime || !year)
        return nil;
    
    NSDateComponents *componentsDayTime = [self components:(NSCalendarUnitMonth|
                                                            NSCalendarUnitDay|
                                                            NSCalendarUnitHour|
                                                            NSCalendarUnitMinute)
                                                  fromDate:dayAndTime];
    NSDateComponents *componentsYear = [self components:NSCalendarUnitYear fromDate:year];
    [componentsDayTime setYear:componentsYear.year];
    return [self dateFromComponents:componentsDayTime];
}

@end
