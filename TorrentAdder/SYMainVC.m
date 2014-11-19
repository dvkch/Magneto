//
//  SYMainVC.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYMainVC.h"
#import "UIView+Glow.h"
#import "SYComputerModel.h"
#import "SYComputerCell.h"
#import "NSData+IPAddress.h"
#import "NSArray+JSON.h"
#import "SYLabelTag.h"
#import "SYAppDelegate.h"
#import "SYAdder.h"
#import "SYWebVC.h"


#define ALERT_VIEW_TAG_OPEN_SOURCE_APP (4)

@interface SYMainVC ()

@end

@implementation SYMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidOpenURL:)
                                                 name:UIAppDidOpenURL
                                               object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    [self.titleLabel addGlow:[UIColor lightGrayColor] size:4.f];
    
    [self.helpButton addGlow:self.helpButton.titleLabel.textColor size:8.f];
    
    [self.headerTorrentLabel setText:@"NO TORRENT PROVIDED"];
    [self.headerTorrentName  setText:@""];
    
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    if(!IOS_VER_GREATER_OR_EQUAL(@"7.0"))
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self->devices  = [[NSMutableArray alloc] init];
    self->services = [[NSMutableArray alloc] init];
    self->serviceBrowsers = [[NSMutableArray alloc] init];
    self->connections = [[NSMutableArray alloc] init];
    
    self->allowedServicesNames = @[@"_afpovertcp._tcp.", @"_smb._tcp."];
    for(NSString *serviceName in self->allowedServicesNames) {
        NSNetServiceBrowser *serviceBrowser = [[NSNetServiceBrowser alloc] init];
        [serviceBrowser setDelegate:self];
        [serviceBrowser searchForServicesOfType:serviceName inDomain:@"local."];
        [self->serviceBrowsers addObject:serviceBrowser];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIAppDidOpenURL
                                                  object:nil];
}

-(void)appDidOpenURL:(id)notification {
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
}

#pragma mark - IBActions

-(IBAction)helpButtonClick:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Help"
                                message:@"To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a computer to start downloading the torrent."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}


#pragma mark - UITableView methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // transmission clients + empty cells (for parallax)
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [self->devices count];
    }
    return ([self->devices count] > 7 ? 0 : (7 - [self->devices count]));
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Available computers";
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellEmpty"];
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellComputer"];
    
    [(SYComputerCell*)cell setTapShort:^(SYComputerModel *computer) {
        [self tappedOnComputer:computer longTap:NO];
    }];
    
    [(SYComputerCell*)cell setTapLong:^(SYComputerModel *computer) {
        [self tappedOnComputer:computer longTap:YES];
    }];
    
    SYComputerModel *computer = [self->devices objectAtIndex:indexPath.row];
    [(SYComputerCell*)cell setComputer:computer];
    
    return cell;
}

-(void)tappedOnComputer:(SYComputerModel*)computer longTap:(BOOL)longTap
{
    if(computer.transmissionPortOpened != PortResult_Opened &&
       computer.uTorrentPortOpened     != PortResult_Opened)
        return;
    
    SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if(!longTap && !appDelegate.url) {
        NSString *message = [NSString stringWithFormat:@"To add a torrent to %@ you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select %@ to start downloading the torrent.",
                             computer.name,
                             computer.name];
        
        [[[UIAlertView alloc] initWithTitle:@"No torrent provided"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];
    }
    
    if(!longTap && appDelegate.url) {
        [[SYAdder shared] setDelegate:self];
        [[SYAdder shared] startRequest:[computer requestForAddingMagnetTransmission:appDelegate.url]
                           forComputer:computer];
    }
    
    if(longTap) {
        self.lastTappedComputer = computer;
        [self performSegueWithIdentifier:@"segueToWeb" sender:self];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleNone;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueToWeb"]) {
        SYWebVC *vc = segue.destinationViewController;
        [vc setComputer:self.lastTappedComputer];
    }
}

#pragma mark - NSNetServiceBrowserDelegate methods

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
          didFindService:(NSNetService *)aNetService
              moreComing:(BOOL)moreComing
{
    [self->services addObject:aNetService];
    [aNetService setDelegate:self];
    [aNetService resolveWithTimeout:0];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
        didRemoveService:(NSNetService *)aNetService
              moreComing:(BOOL)moreComing
{
    [self->services removeObject:aNetService];
}

#pragma mark - NSNetServiceDelegate methods

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
    SYComputerModel *c = [[SYComputerModel alloc] initWithService:sender];
    NSUInteger idx = [self->devices indexOfObject:c];
    if(idx != NSNotFound) {
        SYComputerModel *duplicateC = [self->devices objectAtIndex:idx];
        if(![duplicateC hasHostnameAndIP]) {
            [self->devices removeObjectAtIndex:idx];
            [self->devices addObject:c];
        }
    }
    else {
        [self->devices addObject:c];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate methods (Parallax)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView != self.tableView)
        return;
    
    CGFloat headerViewOffset = -100;
    CGFloat scrollOffset = scrollView.contentOffset.y;
    
    CGFloat parallaxOffest = - (scrollOffset / (scrollOffset < 0 ? 4.f : 8.f));
    
    CGRect frameHeader = self.headerView.frame;
    frameHeader.origin.y = headerViewOffset + parallaxOffest;
    [self.headerView setFrame:frameHeader];
}

#pragma mark - UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == alertView.cancelButtonIndex)
        return;
    
    if(alertView.tag == ALERT_VIEW_TAG_OPEN_SOURCE_APP) {
        SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openAppThatOpenedMe];
    }
}

#pragma mark - SYAdderDelegate methods

-(void)request:(NSURLRequest *)request
   forComputer:(SYComputerModel *)computer
finishedWithResponse:(NSURLResponse *)response
andContentData:(NSData *)contentData
{
    NSInteger code = [(NSHTTPURLResponse*)response statusCode];
    
    NSString        *bodyString = [contentData stringWithUTF8Encoding];
    NSDictionary    *bodyJSON   = [contentData json];
    
    if(code == 200) {
        SYAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSMutableString *message = [NSMutableString string];
        NSString *cancelButton = nil;
        NSString     *okButton = nil;
        
        if(bodyJSON) {
            [message appendFormat:@"Message from %@: %@", computer.name, bodyJSON[@"result"]];
            cancelButton = nil;
            okButton = @"Close";
        }
        
        if(appDelegate.appUrlIsFromParsed != SYAppUnknown) {
            if([message length] > 0)
                [message appendString:@"\n\n"];
            
            [message appendString:@"Do you want to open the app you came from?"];
            cancelButton = @"No";
            okButton = @"Yes";
        }
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Torrent added successfully"
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:cancelButton
                                           otherButtonTitles:okButton, nil];
        
        [av setTag:ALERT_VIEW_TAG_OPEN_SOURCE_APP];
        [av show];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"Message from %@: \n%@",
                             computer.name,
                             bodyString];
        
        [[[UIAlertView alloc] initWithTitle:@"Unknown response"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Close", nil] show];
    }
}

- (void)request:(NSURLRequest*)request
    forComputer:(SYComputerModel*)computer
failedWithError:(NSError*)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error while adding torrent"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}



@end
