//
//  SYResultCell.m
//  TorrentAdder
//
//  Created by syan on 9/28/15.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYResultCell.h"
#import "SYWebAPI.h"
#import "NSDate+TimeAgo.h"
#import "NSAttributedString+SYKit.h"

@interface SYResultCell ()
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@end

@implementation SYResultCell

+ (NSAttributedString *)attributedTitleForResult:(SYResultModel *)result
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title sy_appendString:[result.name stringByAppendingString:@"\n"]
                      font:[UIFont systemFontOfSize:16]
                     color:[UIColor darkTextColor]];
    
    [title sy_appendString:[result.size stringByAppendingString:@", "]
                      font:[UIFont systemFontOfSize:14]
                     color:[UIColor grayColor]];
    
    NSString *dateString = result.age;
    if (result.parsedDate)
    {
        NSTimeInterval aboutTwoMonths = 1440.*3600.;
        dateString = [result.parsedDate timeAgoWithLimit:aboutTwoMonths
                                              dateFormat:NSDateFormatterMediumStyle
                                           andTimeFormat:NSDateFormatterNoStyle];
    }
    
    UIFont *dateFont = [UIFont systemFontOfSize:14];
    if (result.parsedDate && fabs(result.parsedDate.timeIntervalSinceNow) < 48.*3600.)
    {
        dateFont = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    }
    else if (result.parsedDate && fabs(result.parsedDate.timeIntervalSinceNow) < 360.*3600.)
    {
        dateFont = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    }

    [title sy_appendString:[dateString stringByAppendingString:@", " ]
                      font:dateFont
                     color:[UIColor grayColor]];
    
    [title sy_appendString:[NSString stringWithFormat:@"%ld", (long)result.seed]
                      font:[UIFont systemFontOfSize:14]
                     color:[UIColor colorWithRed:0 green:0.56 blue:0.05 alpha:1.]];
    
    [title sy_appendString:@"/"
                      font:[UIFont systemFontOfSize:14]
                     color:[UIColor grayColor]];
    
    [title sy_appendString:[NSString stringWithFormat:@"%ld", (long)result.leech]
                      font:[UIFont systemFontOfSize:14]
                     color:[UIColor redColor]];
    
    return [title copy];
}

- (void)setResult:(SYResultModel *)result
{
    self->_result = result;
    [self.labelName setAttributedText:[[self class] attributedTitleForResult:result]];
}

+ (CGFloat)cellHeightForResult:(SYResultModel *)result
                         width:(CGFloat)width
{
    UILabel *label = [[UILabel alloc] init];
    [label setAttributedText:[self attributedTitleForResult:result]];
    [label setNumberOfLines:0];
    return [label sizeThatFits:CGSizeMake(width - 2 * 15, 1000)].height + 20;
}

@end
