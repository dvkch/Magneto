//
//  SYResultCell.m
//  TorrentAdder
//
//  Created by syan on 9/28/15.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYResultCell.h"
#import "SYResultModel.h"

@interface SYResultCell ()
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@end

@implementation SYResultCell

+ (NSAttributedString *)attributedTitleForResult:(SYResultModel *)result
{
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:[result.name stringByAppendingString:@" "]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                                  NSForegroundColorAttributeName:[UIColor darkTextColor]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:[result.size stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor grayColor]}]];
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
