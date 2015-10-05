//
//  SYComputersCell.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYComputersCell : UITableViewCell

@property (nonatomic, copy) void(^tappedAddComputerBlock)(void);
@property (nonatomic, assign) NSUInteger numberOfComputers;

@end
