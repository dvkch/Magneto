//
//  SYMainVC.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYAdder.h"

@class SYLabelTag;

@interface SYMainVC : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
NSNetServiceBrowserDelegate,
NSNetServiceDelegate,
SYAdderDelegate,
UIAlertViewDelegate>
{
    NSMutableArray *devices;
    NSArray *allowedServicesNames;
    NSMutableArray *services;
    NSMutableArray *serviceBrowsers;
    NSMutableArray *connections;
}

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton    *helpButton;
@property (weak, nonatomic) IBOutlet UIView      *headerView;
@property (weak, nonatomic) IBOutlet SYLabelTag  *headerTorrentLabel;
@property (weak, nonatomic) IBOutlet UILabel     *headerTorrentName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
