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
     [[NSAttributedString alloc] initWithString:[result.name stringByAppendingString:@"\n"]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                                  NSForegroundColorAttributeName:[UIColor darkTextColor]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:[result.size stringByAppendingString:@", "]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor grayColor]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:[result.age stringByAppendingString:@", " ]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor grayColor]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:result.seed
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0.56 blue:0.05 alpha:1.]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:@"/"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor grayColor]}]];
    [title appendAttributedString:
     [[NSAttributedString alloc] initWithString:result.leech
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                  NSForegroundColorAttributeName:[UIColor redColor]}]];
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
