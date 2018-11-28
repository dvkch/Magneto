//
//  SYAddMagnetPopupVC.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 08/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYAddMagnetPopupVC.h"
#import "SYComputerModel.h"
#import "SYDatabase.h"
#import "SYPopoverController.h"
#import "SYClientAPI.h"
#import "NSURL+SY.h"
#import "SYWebAPI.h"
#import "SYComputerCell.h"

@interface SYAddMagnetPopupVC () <UITableViewDataSource, UITableViewDelegate, SYPopoverContentViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *labelStatus;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *buttonBackToApp;
@property (nonatomic, strong) UIButton *buttonOK;
@property (nonatomic, strong) UIButton *buttonCancel;

@property (nonatomic, assign) SYApp appToGoBackTo;
@property (nonatomic, strong) NSURL *magnetURL;
@property (nonatomic, strong) SYResultModel *result;
@property (nonatomic, strong) NSArray *computers;
@property (nonatomic, assign) BOOL canClose;

@end

@interface TESTVC : UIViewController
@end

@implementation SYAddMagnetPopupVC

+ (void)showInViewController:(UIViewController *)viewController
                  withMagnet:(NSURL *)magnet
                    orResult:(SYResultModel *)result
               appToGoBackTo:(SYApp)appToGoBackTo
{
    SYAddMagnetPopupVC *popupVC = [[SYAddMagnetPopupVC alloc] init];
    [popupVC setAppToGoBackTo:appToGoBackTo];
    [popupVC setResult:result];
    [popupVC setMagnetURL:magnet];
    [viewController sy_presentPopover:popupVC animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setCornerRadius:6];
    [self.view.layer setMasksToBounds:YES];
    
    [self setPreferredContentSize:CGSizeMake(300, 250)];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerNib:[UINib nibWithNibName:[SYComputerCell className] bundle:nil]
         forCellReuseIdentifier:[SYComputerCell className]];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    [self.view addSubview:self.tableView];
    
    self.buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonCancel setBackgroundColor:[UIColor clearColor]];
    [self.buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.buttonCancel setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.buttonCancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.buttonCancel addTarget:self action:@selector(buttonCancelTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonCancel];
    
    self.buttonOK = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonOK setBackgroundColor:[UIColor clearColor]];
    [self.buttonOK setTitle:@"Close" forState:UIControlStateNormal];
    [self.buttonOK setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.buttonOK setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.buttonOK addTarget:self action:@selector(buttonOKTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonOK];
    
    self.buttonBackToApp = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonBackToApp setBackgroundColor:[UIColor clearColor]];
    [self.buttonBackToApp setTitle:@"Go back to app" forState:UIControlStateNormal];
    [self.buttonBackToApp setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.buttonBackToApp setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.buttonBackToApp addTarget:self action:@selector(buttonBackToAppTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonBackToApp];
    
    for (UIView *view in @[self.buttonOK, self.buttonCancel, self.buttonBackToApp])
    {
        [view setFrame:CGRectMake(0, 0, 10, 10)];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        [separator setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth)];
        [separator setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.]];
        [view addSubview:separator];
    }
    
    self.labelStatus = [[UILabel alloc] init];
    [self.labelStatus setTextAlignment:NSTextAlignmentCenter];
    [self.labelStatus setNumberOfLines:0];
    [self.labelStatus setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:self.labelStatus];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setColor:[UIColor grayColor]];
    [self.view addSubview:self.spinner];
    
    self.computers = [[SYDatabase shared] computers];
    [self switchToTableView:NO];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    // button height
    CGFloat bh = 40;
    
    [self.tableView         setFrame:CGRectMake(0, 0,          w, h - bh)];
    [self.buttonBackToApp   setFrame:CGRectMake(0, h - bh * 2, w, bh    )];
    [self.buttonOK          setFrame:CGRectMake(0, h - bh,     w, bh    )];
    [self.labelStatus       setFrame:self.tableView.frame];
    [self.buttonCancel      setFrame:self.buttonOK.frame];
    [self.spinner           setCenter:CGPointMake(w/2., h - bh)];
}

#pragma mark - Layouts

- (void)switchToTableView:(BOOL)animated
{
    self.canClose = YES;
    [self.tableView setUserInteractionEnabled:YES];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    [UIView animateWithDuration:(animated ? 0.3 : 0.) animations:^{
        [self.labelStatus       setAlpha:0];
        [self.spinner           setAlpha:0];
        [self.tableView         setAlpha:1];
        [self.buttonBackToApp   setAlpha:0];
        [self.buttonCancel      setAlpha:1];
        [self.buttonOK          setAlpha:0];
    }];
}

- (void)switchToLoading:(BOOL)animated
{
    self.canClose = NO;
    [self.labelStatus setText:@"Loading..."];
    [self.spinner startAnimating];
    [self.tableView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:(animated ? 0.3 : 0.) animations:^{
        [self.labelStatus       setAlpha:1];
        [self.spinner           setAlpha:1];
        [self.tableView         setAlpha:0];
        [self.buttonBackToApp   setAlpha:0];
        [self.buttonCancel      setAlpha:0];
        [self.buttonOK          setAlpha:0];
    }];
}

- (void)switchToFailedWithMessage:(NSString *)message animated:(BOOL)animated
{
    self.canClose = NO;
    [self.labelStatus setText:message];
    [self.tableView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:(animated ? 0.3 : 0.) animations:^{
        [self.labelStatus       setAlpha:1];
        [self.spinner           setAlpha:0];
        [self.tableView         setAlpha:0];
        [self.buttonBackToApp   setAlpha:0];
        [self.buttonCancel      setAlpha:0];
        [self.buttonOK          setAlpha:0];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self switchToTableView:animated];
    });
}

- (void)switchToDoneWithMessage:(NSString *)message animated:(BOOL)animated
{
    self.canClose = YES;
    [self.labelStatus setText:message];
    [self.tableView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:(animated ? 0.3 : 0.) animations:^{
        [self.labelStatus       setAlpha:1];
        [self.spinner           setAlpha:0];
        [self.tableView         setAlpha:0];
        [self.buttonBackToApp   setAlpha:(self.appToGoBackTo == SYAppUnknown ? 0 : 1)];
        [self.buttonCancel      setAlpha:0];
        [self.buttonOK          setAlpha:1];
    }];
}

#pragma mark - Actions

- (void)buttonCancelTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonBackToAppTap:(id)sender
{
    // TODO: [[SYAppDelegate obtain] openApp:self.appToGoBackTo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonOKTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.computers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYComputerCell *cell = [tableView dequeueReusableCellWithIdentifier:[SYComputerCell className]];
    cell.computer = self.computers[indexPath.row];
    cell.isAvailableComputersList = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.result.name.length)
        return self.result.name;
    return [[self.magnetURL magnetName] capitalizedString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self fetchMagnetURLAndAddToComputer:self.computers[indexPath.row]];
}

#pragma mark - Download

- (void)fetchMagnetURLAndAddToComputer:(SYComputerModel *)computer
{
    [self switchToLoading:YES];
    
    if (self.magnetURL)
    {
        [self addToComputer:computer];
        return;
    }
    
    [[SYWebAPI shared] getMagnetForResult:self.result completion:^(NSString *magnet, NSError *error)
    {
        if (error)
        {
            [self switchToFailedWithMessage:error.localizedDescription animated:YES];
        }
        else
        {
            [self setMagnetURL:[NSURL URLWithString:magnet]];
            [self addToComputer:computer];
        }
    }];
}

- (void)addToComputer:(SYComputerModel *)computer
{
    [self switchToLoading:YES];
    [[SYClientAPI shared] addMagnet:self.magnetURL toComputer:computer completion:^(NSString *message, NSError *error) {
        if (error)
        {
            NSString *msg = [NSString stringWithFormat:@"%@\n%@", error.localizedDescription, error.localizedRecoverySuggestion];
            
            if ([error.domain isEqualToString:NSURLErrorDomain])
            {
                if (error.code == NSURLErrorTimedOut ||
                    error.code == NSURLErrorCannotFindHost ||
                    error.code == NSURLErrorCannotConnectToHost ||
                    error.code == NSURLErrorNetworkConnectionLost ||
                    error.code == NSURLErrorNotConnectedToInternet)
                {
                    msg = @"Computer unavailable";
                }
            }
            
            [self switchToFailedWithMessage:msg animated:YES];
        }
        else
        {
            NSString *msg = @"Success!";
            if (message)
                msg = [msg stringByAppendingFormat:@"\n\nMessage from %@:\n%@", computer.name, message];
            [self switchToDoneWithMessage:msg animated:YES];
        }
    }];
}

#pragma mark - PopupNavigationController

- (BOOL)popoverControllerShouldDismissOnBackgroundTap:(SYPopoverController *)popoverController
{
    return self.canClose;
}

- (UIColor *)popoverControllerBackgroundColor:(SYPopoverController *)popoverController
{
    return [UIColor colorWithWhite:0.7 alpha:0.7];
}

@end

