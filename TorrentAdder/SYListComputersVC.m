
//
//  SYListComputersVC.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 24/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYListComputersVC.h"
#import "SYComputerCell.h"
#import <GBPing.h>
#import "SYComputerModel.h"
#import "SYNetworkManager.h"
#import "SYNetworkModel.h"
#import "SYPinger.h"
#import "SYBonjourClient.h"
#import "SYEditComputerVC.h"

@interface SYListComputersVC () <UITableViewDataSource, UITableViewDelegate, GBPingDelegate>

@property (strong, nonatomic) UIBarButtonItem *buttonClose;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSMutableArray <SYComputerModel *> *computers;
@property (strong, nonatomic) SYPinger *pinger;

@end

@implementation SYListComputersVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(buttonCloseTap:)];
    [self.navigationItem setLeftBarButtonItem:self.buttonClose];
    
    self.computers = [NSMutableArray array];
    [self.tableView registerNib:[UINib nibWithNibName:[SYComputerCell className] bundle:nil]
         forCellReuseIdentifier:[SYComputerCell className]];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startPinging];
    [self setTitle:@"Add a computer"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setTitle:@""];
}

- (void)startPinging
{
    if (self.pinger)
        return;
    
    __weak SYListComputersVC *wSelf = self;
    
    [self.progressView setProgress:0];
    
    self.pinger = [SYPinger pingerWithNetworks:[SYNetworkManager myNetworks:YES]];
    [self.pinger pingNetworkWithProgressBlock:^(CGFloat progress) {
        [wSelf.progressView setProgress:progress animated:YES];
    } validIpFoundBlock:^(NSString *ip) {
        [wSelf addComputerWithIP:ip];
    } finishedBlock:^(BOOL finished) {
        [wSelf.progressView setProgress:1 animated:YES];
    }];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)buttonCloseTap:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data

- (void)addComputerWithIP:(NSString *)ip
{
    SYComputerModel *computer = [[SYComputerModel alloc] initWithName:nil andHost:ip];
    [self.computers addObject:computer];
    [self.computers sortUsingComparator:^NSComparisonResult(SYComputerModel * _Nonnull obj1, SYComputerModel * _Nonnull obj2) {
        return [obj1.host compare:obj2.host options:NSNumericSearch];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.computers indexOfObject:computer] inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.computers.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYComputerCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYComputerCell className]];
    
    if (indexPath.row >= self.computers.count)
        [cell setComputer:nil forAvailableComputersList:YES];
    else
        [cell setComputer:self.computers[indexPath.row] forAvailableComputersList:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SYComputerModel *computer;
    
    if (indexPath.row >= self.computers.count)
        computer = [[SYComputerModel alloc] initWithName:nil andHost:nil];
    else
        computer = self.computers[indexPath.row];
    
    SYEditComputerVC *vc = [[SYEditComputerVC alloc] init];
    [vc setComputer:computer];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Available computers";
}

@end
