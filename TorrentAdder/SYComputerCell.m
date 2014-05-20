//
//  SYComputerCell.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYComputerCell.h"
#import "SYComputerModel.h"

#define COLOR_YES ([UIColor greenColor])
#define COLOR_NO  ([UIColor   redColor])

@implementation SYComputerCell

-(void)setComputer:(SYComputerModel *)computer {
    [self setSelected:NO];
    
    self->_computer = computer;
    [self.nameLabel setText:computer.name];
    [self.ipLabel   setText:computer.firstIP4address];
    
    [self.onlineView setBackgroundColor:(self.computer.isPortOpened ? COLOR_YES : COLOR_NO)];
    [self.onlineView.layer setCornerRadius:self.onlineView.frame.size.height / 2.f];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(selected) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.selectedBackgroundCustomView setAlpha:0.25];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                [self.selectedBackgroundCustomView setAlpha:0];
            }];
        }];
    }
    else {
        [self.selectedBackgroundCustomView setAlpha:0];
    }
}

@end
