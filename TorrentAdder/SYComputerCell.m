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

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        UILongPressGestureRecognizer *tapLong = [[UILongPressGestureRecognizer alloc] init];
        [tapLong addTarget:self action:@selector(tapLong:)];
        [tapLong setMinimumPressDuration:0.5];
        
        UITapGestureRecognizer *tapShort = [[UITapGestureRecognizer alloc] init];
        [tapShort addTarget:self action:@selector(tapShort:)];
        [tapShort requireGestureRecognizerToFail:tapLong];
        
        [self.contentView addGestureRecognizer:tapShort];
        [self.contentView addGestureRecognizer:tapLong];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setSelected:YES animated:YES];
}

-(void)tapShort:(id)sender {
    [self setSelected:NO animated:YES];
    if(self.tapShort) self.tapShort(self.computer);
}

-(void)tapLong:(id)sender {
    if([(UIGestureRecognizer*)sender state] != UIGestureRecognizerStateBegan)
        return;
    
    [self setSelected:NO animated:YES];
    if(self.tapLong)  self.tapLong(self.computer);
}

-(void)setComputer:(SYComputerModel *)computer {
    [self setSelected:NO];
    
    self->_computer = computer;
    [self.nameLabel setText:computer.name];
    [self.ipLabel   setText:computer.firstIP4address];
    
    [self.onlineView setBackgroundColor:COLOR_NO];
    if(self.computer.transmissionPortOpened || self.computer.uTorrentPortOpened)
        [self.onlineView setBackgroundColor:COLOR_YES];
    
    [self.onlineView.layer setCornerRadius:self.onlineView.frame.size.height / 2.f];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.selectedBackgroundCustomView setAlpha:(selected ? 0.25 : 0)];
    }];
}

@end
