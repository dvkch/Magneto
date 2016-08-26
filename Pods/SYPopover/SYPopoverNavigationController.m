//
//  SYPopoverNavigationController.m
//  SYPopover
//
//  Created by Stanislas Chevallier on 04/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYPopoverNavigationController.h"
#import "SYPopoverViewController.h"
#import "SYPopoverAnimator.h"

#import "UIDevice+SYKit.h"
#import "UIScreen+SYKit.h"

@interface SYPopoverNavigationController ()
<SYPopoverViewControllerDelegate,
UINavigationControllerDelegate,
UIViewControllerTransitioningDelegate>
@end

@implementation SYPopoverNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    [self setDelegate:self];
    
    if(self.backgroundsColor)
        [self.view setBackgroundColor:self.backgroundsColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.popoverDelegate respondsToSelector:@selector(popoverNavigationControllerWillPresent:animated:)])
        [self.popoverDelegate popoverNavigationControllerWillPresent:self animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.popoverDelegate respondsToSelector:@selector(popoverNavigationControllerWillDismiss:animated:)] &&
        !self.presentedViewController) // prevents being called when displaying tutorial
        [self.popoverDelegate popoverNavigationControllerWillDismiss:self animated:animated];
}

- (void)setBackgroundsColor:(UIColor *)backgroundsColor
{
    self->_backgroundsColor = backgroundsColor;
    [self.view setBackgroundColor:backgroundsColor];
}

- (instancetype)initWithRootViewController:(SYPopoverViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    return self;
}


#pragma mark - Presentation

- (void)presentAsPopoverFromViewController:(UIViewController *)viewController
                                  animated:(BOOL)animated
{
    if([UIDevice sy_iOSis8Plus]) {
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self setTransitioningDelegate:self];
    }
    else if([UIDevice sy_iOSis7Plus]) {
        // needed for rotation events to come
        [self setModalPresentationStyle:UIModalPresentationCustom];
        
        // needed for transparent background
        viewController.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        // needed for the view behind to receive rotation events -> dunno anymore, but
        // it's still very fucked up if in landscape
        //if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        //    animated = NO;
        
        [self setTransitioningDelegate:self];
    }
    else {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewController.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    [viewController.navigationController presentViewController:self animated:animated completion:nil];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllers stack

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(self.backgroundsColor)
        [viewController.view setBackgroundColor:self.backgroundsColor];
    
    if(animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortrait:
                transition.subtype = kCATransitionFromRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                transition.subtype = kCATransitionFromLeft;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                transition.subtype = kCATransitionFromBottom;
                break;
            case UIInterfaceOrientationLandscapeRight:
                transition.subtype = kCATransitionFromTop;
                break;
        }
        if([UIDevice sy_iOSis8Plus])
            transition.subtype = kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    
    [super pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if(animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        
        if (![UIDevice sy_iOSis8Plus]) {
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationUnknown:
                case UIInterfaceOrientationPortrait:
                    transition.subtype = kCATransitionFromLeft;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    transition.subtype = kCATransitionFromRight;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    transition.subtype = kCATransitionFromTop;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    transition.subtype = kCATransitionFromBottom;
                    break;
            }
        }
        
        [self.view.layer addAnimation:transition forKey:kCATransition];
    }
    
    return [super popViewControllerAnimated:NO];
}

#pragma mark - UINavigationControllerDelegate methods

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    if([viewController isKindOfClass:[SYPopoverViewController class]])
        [(SYPopoverViewController *)viewController setPopoverDelegate:self];
}

#pragma mark - SYPopoverViewControllerDelegate methods

-(BOOL)popoverViewControllerShouldDismiss:(SYPopoverViewController *)popoverViewController
{
    if ([self.popoverDelegate respondsToSelector:@selector(popoverNavigationControllerShouldDismiss:)]) {
        return [self.popoverDelegate popoverNavigationControllerShouldDismiss:self];
    }
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[SYPopoverAnimator alloc] initForPresenting:YES];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[SYPopoverAnimator alloc] initForPresenting:NO];
}

@end
