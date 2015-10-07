//
//  SYMainVC.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYMainVC.h"
#import "SYComputerModel.h"
#import "SYComputerCell.h"
#import "SYComputersCell.h"
#import "SYAppDelegate.h"
#import "SYWebVC.h"
#import "SYButton.h"
#import "SYListComputersVC.h"
#import "SYResultCell.h"
#import "SYKickAPI.h"
#import "SYAlertManager.h"
#import "SYDatabase.h"
#import "SYEditComputerVC.h"
#import "UIColor+SY.h"
#import "SYNetworkManager.h"
#import "UIView+Glow.h"
#import "SYSearchField.h"

#define ALERT_VIEW_TAG_OPEN_SOURCE_APP (4)

@interface SYMainVC () <UITableViewDataSource, UITableViewDelegate, SYNetworkManagerDelegate, SYSearchFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel        *titleLabel;
@property (weak, nonatomic) IBOutlet UIView         *headerView;
@property (weak, nonatomic) IBOutlet SYSearchField  *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBlueHeaderHeight;

@property (strong, nonatomic) NSArray *computers;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSString *searchQuery;
@property (assign, nonatomic) CGFloat constraintBlueHeaderHeightOriginalValue;

@end

@implementation SYMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SYNetworkManager shared] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidOpenURL:)
                                                 name:UIAppDidOpenURL
                                               object:nil];
    
    [self.titleLabel addGlow:[UIColor lightGrayColor] size:4.f];
    
    [self.searchField setBackgroundColor:[UIColor colorWithWhite:1. alpha:0.3]];
    [self.searchField.activityIndicatorView setColor:[UIColor blackColor]];
    [self.searchField.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.searchField.textField setPlaceholder:@"Search"];
    
    [self.tableView registerNib:[UINib nibWithNibName:[SYComputersCell className] bundle:nil]
         forCellReuseIdentifier:[SYComputersCell className]];
    [self.tableView registerNib:[UINib nibWithNibName:[SYComputerCell className] bundle:nil]
         forCellReuseIdentifier:[SYComputerCell className]];
    [self.tableView registerNib:[UINib nibWithNibName:[SYResultCell className] bundle:nil]
         forCellReuseIdentifier:[SYResultCell className]];
    [self.tableView setDelaysContentTouches:NO];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    self.constraintBlueHeaderHeightOriginalValue = self.constraintBlueHeaderHeight.constant;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    self.computers = [[SYDatabase shared] computers];
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIAppDidOpenURL
                                                  object:nil];
}

- (void)appDidOpenURL:(id)notification
{
    /*
    SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *urlString = [appDelegate.url description];
    
    if(!appDelegate.url) {
        [self.headerTorrentLabel setText:@"NO TORRENT PROVIDED"];
        [self.headerTorrentName  setText:@""];
    }
    else if([urlString rangeOfString:@"magnet:"].location == 0) {
        [self.headerTorrentLabel setText:@"MAGNET"];
        [self.headerTorrentName  setText:urlString];
        
        NSArray *urlComps = [urlString componentsSeparatedByString:@"&"];
        for(NSString *comp in urlComps) {
            if([comp rangeOfString:@"dn="].location == 0) {
                NSArray *urlComps2 = [comp componentsSeparatedByString:@"="];
                if([urlComps2 count] == 2) {
                    NSString *dn = [urlComps2 objectAtIndex:1];
                    dn = [dn stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    [self.headerTorrentName setText:dn];
                }
            }
        }
    }
     */
}

#pragma mark - IBActions

- (IBAction)helpButtonClick:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Help"
                                message:@"To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a computer to start downloading the torrent."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.searchResults ? 0 : 1;
    if (section == 1)
        return self.searchResults ? 0 : self.computers.count;
    return self.searchResults.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return self.searchResults ? nil : @"Available computers";
    if (section == 1)
        return nil;
    return self.searchResults ? @"Results" : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak SYMainVC *wSelf = self;
    if (indexPath.section == 0)
    {
        SYComputersCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYComputersCell className]];
        [cell setNumberOfComputers:self.computers.count];
        [cell setTappedAddComputerBlock:^{
            SYListComputersVC *vc = [[SYListComputersVC alloc] init];
            SYNavigationController *nc = [[SYNavigationController alloc] initWithRootViewController:vc];
            [wSelf.navigationController presentViewController:nc animated:YES completion:nil];
        }];
        return cell;
    }
    if (indexPath.section == 1)
    {
        SYComputerCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYComputerCell className]];
        [cell setComputer:self.computers[indexPath.row] forAvailableComputersList:NO];
        return cell;
    }
    
    SYResultCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYResultCell className]];
    [cell setResult:self.searchResults[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
        return 60;
    return [SYResultCell cellHeightForResult:self.searchResults[indexPath.row] width:tableView.frame.size.width];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        SYListComputersVC *vc = [[SYListComputersVC alloc] init];
        SYNavigationController *nc = [[SYNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nc animated:YES completion:nil];
    }
    if (indexPath.section == 1)
    {
        SYEditComputerVC *vc = [[SYEditComputerVC alloc] init];
        [vc setComputer:self.computers[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 2)
    {
        NSLog(@"wants to download %@", self.searchResults[indexPath.row]);
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        SYWebVC *vc = [[SYWebVC alloc] init];
        [vc setComputer:self.computers[indexPath.row]];
        SYNavigationController *nc = [[SYNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nc animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[SYDatabase shared] removeComputer:self.computers[indexPath.row]];
        
        NSMutableArray *computers = [self.computers mutableCopy];
        [computers removeObjectAtIndex:indexPath.row];
        self.computers = [computers copy];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

/*
- (void)tappedOnComputer:(SYComputerModel*)computer
{
    SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.url)
    {
        [[SYClientAPI shared] addMagnet:appDelegate.url toComputer:computer completion:^(NSString *message, NSError *error) {
            [SYAlertManager showMagnetAddedToComputer:computer
                                          withMessage:message
                                                error:error
                                            backToApp:(appDelegate.appUrlIsFromParsed != SYAppUnknown)
                                                block:^(BOOL backToApp)
             {
                 if (backToApp)
                 {
                     [appDelegate openAppThatOpenedMe];
                 }
             }];
        }];
        return;
    }
    
    [SYAlertManager showHelpMagnetAlertForComputer:computer];
}
*/

#pragma mark - Search

- (void)searchFieldDidReturn:(SYSearchField *)searchField withText:(NSString *)text
{
    [self setSearchQuery:text];
}

- (void)setSearchQuery:(NSString *)searchQuery
{
    self->_searchQuery = searchQuery;
    
    if (!self.searchQuery.length)
    {
        self.searchResults = nil;
        [self.tableView reloadData];
        return;
    }
    
    [self.searchField setTitleText:searchQuery];
    [self.searchField showLoadingIndicator:YES];
    
    [[SYKickAPI shared] lookFor:self.searchQuery
            withCompletionBlock:^(NSArray *items, NSError *error)
    {
        if (![self.searchQuery isEqualToString:searchQuery])
            return;
        
        [self.searchField showLoadingIndicator:NO];
        self.searchResults = [items copy];
        [self.tableView reloadData];
        
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Cannot load results"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Close", nil] show];
        }
        else
        {
            NSLog(@"Results: %@", items);
        }
    }];
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.searchQuery = textField.text;
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField resignFirstResponder];
    });
    self.searchQuery = textField.text;
    return YES;
}

#pragma mark - Parallax

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0)
        self.constraintBlueHeaderHeight.constant =
        self.constraintBlueHeaderHeightOriginalValue - scrollView.contentOffset.y;
    else
        self.constraintBlueHeaderHeight.constant =
        self.constraintBlueHeaderHeightOriginalValue;
    
    [self.searchField.textField resignFirstResponder];
}

#pragma mark - SYNetworkManager delegate

- (void)networkManager:(SYNetworkManager *)networkManager changedStatusForComputer:(SYComputerModel *)computer
{
    NSUInteger idx = [self.computers indexOfObject:computer];
    if (idx == NSNotFound)
        return;
    
    SYComputerCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:1]];
    [cell setComputer:cell.computer forAvailableComputersList:NO];
}

@end
