//
//  NSURL+SY.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 08/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSURL+SY.h"

@implementation NSURL (SY)

- (NSString *)magnetName
{
    NSArray *urlComps = [self.absoluteString componentsSeparatedByString:@"&"];
    for(NSString *comp in urlComps) {
        if([comp rangeOfString:@"dn="].location == 0) {
            NSArray *urlComps2 = [comp componentsSeparatedByString:@"="];
            if([urlComps2 count] == 2) {
                NSString *dn = [urlComps2 objectAtIndex:1];
                dn = [dn stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                return dn;
            }
        }
    }
    return nil;
}

@end
