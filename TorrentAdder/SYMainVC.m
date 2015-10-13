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
#import "SYAddMagnetPopupVC.h"
#import "SYResultModel.h"
#import "NSString+SYApp.h"

#define ALERT_VIEW_TAG_OPEN_SOURCE_APP (4)

@interface SYMainVC () <UITableViewDataSource, UITableViewDelegate, SYSearchFieldDelegate>

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidOpenURL:)
                                                 name:UIAppDidOpenURLNotification
                                               object:nil];
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIAppDidOpenURLNotification
                                                  object:nil];
}

- (void)appDidOpenURL:(NSNotification *)notification
{
    NSString *appID = notification.userInfo[UIAppDidOpenURLNotification_AppIDKey];
    NSURL *magnetURL = notification.userInfo[UIAppDidOpenURLNotification_MagnetURLKey];
    
    [SYAddMagnetPopupVC showInViewController:self
                                  withMagnet:magnetURL
                               appToGoBackTo:[appID parsedSYApp]];
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
        SYWebVC *vc = [[SYWebVC alloc] init];
        [vc setComputer:self.computers[indexPath.row]];
        SYNavigationController *nc = [[SYNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nc animated:YES completion:nil];
    }
    if (indexPath.section == 2)
    {
        if (!self.computers.count)
        {
            [SYAlertManager showNoComputerAlert];
            return;
        }
        
        SYResultModel *result = self.searchResults[indexPath.row];
        [SYAddMagnetPopupVC showInViewController:self withMagnet:[NSURL URLWithString:result.magnet] appToGoBackTo:SYAppUnknown];
    }
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
    
    [[SYKickAPI shared] lookFor:self.searchQuery
            withCompletionBlock:^(NSArray *items, NSError *error)
    {
        if (![self.searchQuery isEqualToString:searchQuery])
            return;
        
        [self.searchField showLoadingIndicator:NO];
        self.searchResults = [items copy];
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        if (error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Cannot load results"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Close", nil] show];
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

@end
