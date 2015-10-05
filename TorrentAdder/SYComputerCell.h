//
//  SYComputerCell.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYComputerModel;

@interface SYComputerCell : UITableViewCell

- (void)setComputer:(SYComputerModel *)computer forAvailableComputersList:(BOOL)forAvailableComputersList;

@end
