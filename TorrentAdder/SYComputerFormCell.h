//
//  SYComputerFormCell.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYComputerModel+UI.h"

@interface SYComputerFormCell : UITableViewCell

- (void)setComputer:(SYComputerModel *)computer andField:(SYComputerModelField)field;

@end
