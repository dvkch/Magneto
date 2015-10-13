//
//  SYComputerCell.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYComputerCell.h"
#import "SYComputerModel.h"
#import "SYNetworkManager.h"

#define COLOR_YES ([UIColor greenColor])
#define COLOR_NO  ([UIColor   redColor])

@interface SYComputerCell ()
@property (weak,   nonatomic) IBOutlet UILabel      *nameLabel;
@property (weak,   nonatomic) IBOutlet UILabel      *hostLabel;
@property (weak,   nonatomic) IBOutlet UIImageView  *statusImageView;
@property (weak,   nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic, readwrite) SYComputerModel *computer;
@property (assign, nonatomic) BOOL forAvailableComputersList;
@end

@implementation SYComputerCell

- (void)setComputer:(SYComputerModel *)computer
{
    if (self.computer)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:SYNetworkManagerComputerStatusChangedNotification
                                                      object:self.computer];
        
    }

    self->_computer = computer;
    
    if (self.computer)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationComputerStatusChanged:)
                                                     name:SYNetworkManagerComputerStatusChangedNotification
                                                   object:self.computer];
    }
}

- (void)dealloc
{
    if (self.computer)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationComputerStatusChanged:)
                                                     name:SYNetworkManagerComputerStatusChangedNotification
                                                   object:self.computer];
    }
}

- (void)setComputer:(SYComputerModel *)computer forAvailableComputersList:(BOOL)forAvailableComputersList
{
    
    [self setAccessoryType:(forAvailableComputersList ?
                            UITableViewCellAccessoryDisclosureIndicator :
                            UITableViewCellAccessoryNone)];
    
    [self setComputer:computer];
    [self setForAvailableComputersList:forAvailableComputersList];
    
    self->_computer = computer;

    if (self.computer)
    {
        [self.nameLabel setText:computer.name];
        if (forAvailableComputersList)
        {
            [self.hostLabel setText:computer.host];
        }
        else
        {
            [self.hostLabel setText:[NSString stringWithFormat:@"%@:%d",
                                     computer.host, computer.port]];
        }
    }
    else
    {
        [self.nameLabel setText:@"Add a custom computer"];
        [self.hostLabel setText:@"in case yours wasn't detected"];
    }
    
    [self updateStatus];
}

- (void)updateStatus
{
    SYComputerStatus status = SYComputerStatus_Unknown;
    if (!self.forAvailableComputersList)
        status = [[SYNetworkManager shared] statusForComputer:self.computer];
    if (self.forAvailableComputersList &&  self.computer)
        status = SYComputerStatus_Opened;
    if (self.forAvailableComputersList && !self.computer)
        status = SYComputerStatus_Waiting;
    
    switch (status)
    {
        case SYComputerStatus_Unknown:
            [self.statusImageView setImage:nil];
            [self.activityIndicator stopAnimating];
            break;
        case SYComputerStatus_Waiting:
            [self.statusImageView setImage:nil];
            [self.activityIndicator startAnimating];
            break;
        case SYComputerStatus_Closed:
            [self.statusImageView setImage:[UIImage imageNamed:@"traffic_grey"]];
            [self.activityIndicator stopAnimating];
            break;
        case SYComputerStatus_Opened:
            [self.statusImageView setImage:[UIImage imageNamed:@"traffic_green"]];
            [self.activityIndicator stopAnimating];
            break;
    }
}

- (void)notificationComputerStatusChanged:(NSNotification *)notification
{
    [self updateStatus];
}

@end
