//
//  SYPopoverTransitioningDelegate.m
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import "SYPopoverTransitioningDelegate.h"
#import "SYPopoverTransitions.h"
#import "SYPopoverController.h"

@implementation SYPopoverTransitioningDelegate

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static SYPopoverTransitioningDelegate *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[SYPopoverController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return [[SYPopoverPresentationTransition alloc] initForPresenting:YES];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[SYPopoverPresentationTransition alloc] initForPresenting:NO];
}


@end
