//
//  SYResultCell.h
//  TorrentAdder
//
//  Created by syan on 9/28/15.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYResultModel;

@interface SYResultCell : UITableViewCell

@property (nonatomic, strong) SYResultModel *result;

+ (CGFloat)cellHeightForResult:(SYResultModel *)result
                         width:(CGFloat)width;

@end
