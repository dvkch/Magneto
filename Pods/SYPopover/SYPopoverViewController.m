//
//  SYPopoverViewController.m
//  TicTacDoh
//
//  Created by Stanislas Chevallier on 26/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYPopoverViewController.h"
#import "UIDevice+SYKit.h"
#import "UIScreen+SYKit.h"
#import "SYPopoverNavigationController.h"
#import "SYScreenHelper.h"
#import "CGTools.h"

@interface SYPopoverViewController ()
@property (nonatomic, strong) UITapGestureRecognizer *tappedOutsideGestureRecognizer;
@property (nonatomic, strong) UIView *underPopoverView;
@end

@implementation SYPopoverViewController

- (void)loadView
{
    [super loadView];
    [self.view setAutoresizesSubviews:NO];
    
    self.popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.popoverView setBackgroundColor:[UIColor colorWithWhite:0.6f alpha:1]];
    [self.popoverView.layer setCornerRadius:5.f];
    [self.popoverView.layer setMasksToBounds:YES];
    [self.popoverView setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin)
];
    [self.view addSubview:self.popoverView];
    
    self.underPopoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.underPopoverView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    [self.view addSubview:self.underPopoverView];
    [self.view sendSubviewToBack:self.underPopoverView];
    
    self.tappedOutsideGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self.tappedOutsideGestureRecognizer setNumberOfTapsRequired:1];
    [self.tappedOutsideGestureRecognizer setNumberOfTouchesRequired:1];
    [self.tappedOutsideGestureRecognizer addTarget:self action: @selector(tappedOutsideGestureRecognizerTap:)];
    [self.underPopoverView addGestureRecognizer:self.tappedOutsideGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    [self updateFramesForOrientation:self.interfaceOrientation duration:0];
}

- (void)setPopoverSizeBlock:(CGSize (^)(BOOL, BOOL))popoverSizeBlock
{
    self->_popoverSizeBlock = [popoverSizeBlock copy];
    [self updateFramesForOrientation:self.interfaceOrientation duration:0];
}

- (void)updateFramesForOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [[SYScreenHelper shared] updateStatusBarVisibility:orientation animated:(duration != 0)];
    
    CGSize s = self.preferredContentSize;
    if(!UIInterfaceOrientationIsPortrait(orientation))
        s = CGSizeMake(s.height, s.width);
    
    [UIView animateWithDuration:duration animations:^{
        [self.popoverView setFrame:CGRectCenteredInsideRectWithSize([[SYScreenHelper shared] screenRect:orientation], s, YES)];
        [self.underPopoverView setFrame:[[SYScreenHelper shared] fullScreenRect:orientation]];
        [self updateFramesAndAlphas];
    }];
}

- (CGSize)preferredContentSize
{
    BOOL iPhoneSmallScreen = [[UIScreen mainScreen] boundsFixedToPortraitOrientation].size.height < 490;
    
    if(self.popoverSizeBlock)
        return self.popoverSizeBlock([[UIDevice currentDevice] isIpad], iPhoneSmallScreen);
    
    if([[UIDevice currentDevice] isIpad])
        return CGSizeMake(400, 400);
    
    return CGSizeMake(300, 300);
}

- (void)updateFramesAndAlphas
{
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateFramesForOrientation:toInterfaceOrientation duration:duration];
}

- (void)tappedOutsideGestureRecognizerTap:(id)sender
{
    CGPoint p = [self.tappedOutsideGestureRecognizer locationInView:self.popoverView];
    BOOL outside = !CGRectContainsPoint(self.popoverView.bounds, p);
    if(outside) {
        if ([self.popoverDelegate respondsToSelector:@selector(popoverViewControllerShouldDismiss:)]) {
            if([self.popoverDelegate popoverViewControllerShouldDismiss:self])
                [self close];
        }
        else {
            [self close];
        }
    }
}

- (void)close
{
    if(![self.navigationController isKindOfClass:[SYPopoverNavigationController class]]) {
        [self.navigationController dismissViewControllerAnimated:[UIDevice iOSis8Plus] completion:nil];
        return;
    }
    
    SYPopoverNavigationController *nc = (SYPopoverNavigationController *)self.navigationController;
    [nc close];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
