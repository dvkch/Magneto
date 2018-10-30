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
#import "SYButton.h"
#import "SYListComputersVC.h"
#import "SYResultCell.h"
#import "SYWebAPI.h"
#import "SYDatabase.h"
#import "SYEditComputerVC.h"
#import "UIColor+SY.h"
#import "SYNetworkManager.h"
#import "UIView+Glow.h"
#import "SYSearchField.h"
#import "SYAddMagnetPopupVC.h"
#import "NSString+SYApp.h"
#import "SYWebAPI.h"
#import "SYPopoverController.h"
#import <SafariServices/SafariServices.h>


#define ALERT_VIEW_TAG_OPEN_SOURCE_APP (4)

@interface SYMainVC () <UITableViewDataSource, UITableViewDelegate, SYSearchFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel        *titleLabel;
@property (weak, nonatomic) IBOutlet UIView         *headerView;
@property (weak, nonatomic) IBOutlet SYSearchField  *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBlueHeaderHeight;

@property (strong, nonatomic) NSTimer *timerRefreshComputers;
@property (strong, nonatomic) NSArray <SYComputerModel *> *computers;
@property (strong, nonatomic) NSArray <SYResultModel *> *searchResults;
@property (strong, nonatomic) NSString *searchQuery;
@property (assign, nonatomic) CGFloat constraintBlueHeaderHeightOriginalValue;
@property (assign, nonatomic) BOOL isVisible;

@end

@implementation SYMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidOpenURL:)
                                                 name:UIAppDidOpenURLNotification
                                               object:nil];
    
    self.timerRefreshComputers = [NSTimer timerWithTimeInterval:5
                                                         target:self
                                                       selector:@selector(refreshComputersTimerTick:)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerRefreshComputers forMode:NSRunLoopCommonModes];
    
    [self.titleLabel addGlow:[UIColor lightGrayColor] size:4.f];
    
    [self.searchField setBackgroundColor:[UIColor colorWithWhite:1. alpha:0.3]];
    [self.searchField.activityIndicatorView setColor:[UIColor blackColor]];
    [self.searchField.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.searchField.textField setPlaceholder:@"Search"];
    [self.searchField.textField setRightViewMode:UITextFieldViewModeAlways];
    [self.searchField.textField setClearButtonMode:UITextFieldViewModeAlways];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIAppDidOpenURLNotification
                                                  object:nil];
    
    [self.timerRefreshComputers invalidate];
}

- (void)appDidOpenURL:(NSNotification *)notification
{
    NSString *appID = notification.userInfo[UIAppDidOpenURLNotification_AppIDKey];
    NSURL *magnetURL = notification.userInfo[UIAppDidOpenURLNotification_MagnetURLKey];
    
    [SYAddMagnetPopupVC showInViewController:self
                                  withMagnet:magnetURL
                                    orResult:nil
                               appToGoBackTo:[appID parsedSYApp]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBActions

- (IBAction)helpButtonClick:(id)sender
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Help"
                                        message:@"To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a computer to start downloading the torrent."
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    // section 2
    if (self.searchResults.count)
        return @"Results";
    if (self.searchResults)
        return @"No results";
    return nil;
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
        SYComputerModel *computer = self.computers[indexPath.row];
        SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:computer.webURL];
        if (@available(iOS 10, *)) {
            vc.preferredBarTintColor = [UIColor lightBlueColor];
        }
        [self presentViewController:vc animated:YES completion:nil];
    }
    if (indexPath.section == 2)
    {
        if (!self.computers.count)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot add torent"
                                                                           message:@"No computer saved in your settings, please add one before trying to download this item"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        SYResultModel *result = self.searchResults[indexPath.row];
        [SYAddMagnetPopupVC showInViewController:self withMagnet:nil orResult:result appToGoBackTo:SYAppUnknown];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // needed on iOS8 to show row actions
}

- (NSArray<UITableViewRowAction *> * _Nullable)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    __weak SYMainVC *wSelf = self;
    if (indexPath.section == 1)
    {
        UITableViewRowAction *editAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:
         ^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
         {
             SYEditComputerVC *vc = [[SYEditComputerVC alloc] init];
             [vc setComputer:wSelf.computers[indexPath.row]];
             [wSelf.navigationController pushViewController:vc animated:YES];
         }];
        
        UITableViewRowAction *deleteAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:
         ^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
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
         }];
        return @[deleteAction, editAction];
    }
    
    if (indexPath.section == 2)
    {
        UITableViewRowAction *shareAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share page link" handler:
         ^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
         {
             SYResultModel *result = wSelf.searchResults[indexPath.row];
             
             UIActivityViewController *activityVC =
             [[UIActivityViewController alloc] initWithActivityItems:@[[result fullURL]] applicationActivities:nil];
             [activityVC.popoverPresentationController setSourceRect:[wSelf.tableView cellForRowAtIndexPath:indexPath].frame];
             [activityVC.popoverPresentationController setSourceView:wSelf.view];
             // TODO: use better sourceRect (centered ?) and arrowDirection
             
             [wSelf presentViewController:activityVC animated:YES completion:nil];
             [wSelf.tableView setEditing:NO animated:YES];
         }];
        [shareAction setBackgroundColor:[UIColor colorWithRed:14./255. green:162./255. blue:1. alpha:1.]];
        return @[shareAction];
    }
    return nil;
}

#pragma mark - Search

- (void)searchFieldDidReturn:(SYSearchField *)searchField withText:(NSString *)text
{
    [self setSearchQuery:text];
}

- (void)setSearchQuery:(NSString *)searchQuery
{
    self->_searchQuery = searchQuery;
    [self.searchField setTitleText:searchQuery];
    
    if (!self.searchQuery.length)
    {
        self.searchResults = nil;
        [self.tableView reloadData];
        return;
    }
    
    [self.searchField showLoadingIndicator:YES];
    [[SYWebAPI shared] lookFor:self.searchQuery
                    completion:^(NSArray *items, NSError *error)
    {
        if (![self.searchQuery isEqualToString:searchQuery])
            return;
        
        [self.searchField showLoadingIndicator:NO];
        self.searchResults = [items copy];
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        if (error)
        {
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Cannot load results"
                                                message:error.localizedDescription
                                         preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - Timer

- (void)refreshComputersTimerTick:(id)sender
{
    if (!self.isVisible)
        return;
    
    for (SYComputerModel *computer in self.computers)
        [[SYNetworkManager shared] startStatusUpdateForComputer:computer];
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
}

@end
