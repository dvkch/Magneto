//
//  SYComputersCell.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYComputersCell.h"
#import "SYButton.h"

@interface SYComputersCell ()
@property (nonatomic, weak) IBOutlet SYButton *buttonAdd;
@property (nonatomic, weak) IBOutlet UILabel *labelCount;
@end

@implementation SYComputersCell

- (void)setNumberOfComputers:(NSInteger)numberOfComputers
{
    self->_numberOfComputers = numberOfComputers;
    [self.labelCount setText:[NSString stringWithFormat:@"%d computer%@",
                              (int)numberOfComputers,
                              numberOfComputers > 1 ? @"s" : @""]];
}

- (IBAction)buttonAddTap:(id)sender
{
    if (self.tappedAddComputerBlock)
        self.tappedAddComputerBlock();
}

@end
