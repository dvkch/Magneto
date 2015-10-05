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

- (void)setResult:(SYResultModel *)result
{
    self->_result = result;
    [self.labelName setText:result.name];
}

+ (CGFloat)cellHeightForResult:(SYResultModel *)result
                         width:(CGFloat)width
{
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setText:result.name];
    [label setNumberOfLines:0];
    return [label sizeThatFits:CGSizeMake(width - 2 * 15, 1000)].height + 20;
}

@end
