//
//  SYEditComputerVC.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYEditComputerVC.h"
#import "SYComputerFormCell.h"
#import "SYDatabase.h"
#import "UIColor+SY.h"
#import "SYButton.h"

@interface SYEditComputerVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isCreation;
@end

@implementation SYEditComputerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.isCreation = ([[SYDatabase shared] computerWithID:self.computer.identifier] ? NO : YES);
    [self setTitle:(self.isCreation ? @"New Computer" : @"Edit Computer")];
    
    [self.tableView registerNib:[UINib nibWithNibName:[SYComputerFormCell className] bundle:nil]
         forCellReuseIdentifier:[SYComputerFormCell className]];
    
    if (self.isCreation)
    {
        SYButton *buttonAdd = [[SYButton alloc] init];
        [buttonAdd setTintColor:[UIColor whiteColor]];
        [buttonAdd setBackColor:[UIColor lightBlueColor]];
        [buttonAdd setText:@"+"];
        [buttonAdd setTextVOffset:-2];
        [buttonAdd setFontSize:30];
        [buttonAdd addTarget:self action:@selector(buttonSaveTap:) forControlEvents:UIControlEventTouchUpInside];
        [buttonAdd setFrame:CGRectMake(0, 0, 50, 50)];
        [buttonAdd setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleBottomMargin)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [view addSubview:buttonAdd];
        [buttonAdd setCenter:view.center];
        [self.tableView setTableFooterView:view];
    }
    else
    {
        [self.tableView setTableFooterView:[[UIView alloc] init]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.isCreation)
        [[SYDatabase shared] addComputer:self.computer];
}

- (void)setComputer:(SYComputerModel *)computer
{
    self->_computer = computer;
    [self.tableView reloadData];
}

#pragma mark - IBActions

- (void)buttonSaveTap:(id)sender
{
    if (self.computer.port == 0)
        [self.computer setPort:[SYComputerModel defaultPortForClient:self.computer.client]];
    
    if (![self.computer isValid])
        return;
    
    [[SYDatabase shared] addComputer:self.computer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SYComputerModel numberOfFields];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYComputerFormCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYComputerFormCell className]];
    [cell setComputer:self.computer andField:(SYComputerModelField)indexPath.row];
    return cell;
}

@end
