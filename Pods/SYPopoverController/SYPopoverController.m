//
//  SYPopoverController.m
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import "SYPopoverController.h"

@interface SYPopoverController () <UINavigationControllerDelegate>
@property (nonatomic, strong, readwrite) UIView *backgroundView;
@property (nonatomic, weak) id<SYPopoverControllerDelegate> popoverDelegate;
@property (nonatomic, assign) CGRect oldRect;
@end

@implementation SYPopoverController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self)
    {
        if ([presentedViewController isKindOfClass:[UINavigationController class]])
        {
            [(UINavigationController *)presentedViewController setDelegate:self];
            
            // This one is tricky
            //
            // Animating a push/pop between VC 1 and VC 2 will grow the NC preferredContentSize if the
            // preferredContentSize of VC1 and VC2 cannot fit in it; but this breaks the animation of the
            // containerView's size when doing so.
            //
            // The only fix is to use an already big enough content size to prevent it from growing. 2000px seems
            // big enough since no device has a logical screen size this big (yet?)
            [presentedViewController setPreferredContentSize:CGSizeMake(2000, 2000)];
        }
        
        if ([presentingViewController conformsToProtocol:@protocol(SYPopoverControllerDelegate)])
            [self setPopoverDelegate:(id<SYPopoverControllerDelegate>)presentingViewController];
        
        UITapGestureRecognizer *tapOutside =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside:)];
        
        self.backgroundView = [[UIView alloc] init];
        [self.backgroundView addGestureRecognizer:tapOutside];
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGSize size = self.topViewController.preferredContentSize;
    return CGRectMake((self.containerView.frame.size.width  - size.width)  / 2.,
                      (self.containerView.frame.size.height - size.height) / 2.,
                      size.width, size.height);
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id <UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    [self updateAppearance];
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    [self updateAppearance];
}

- (UIModalPresentationStyle)adaptivePresentationStyle
{
    return UIModalPresentationFullScreen;
}

#pragma mark - Actions

- (void)tapOutside:(id)sender
{
    if ([self shouldDismissOnBackgroundTap])
    {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Customization

- (UIViewController *)topViewController
{
    UIViewController *vc = self.presentedViewController;
    BOOL updated = YES;
    
    while (updated)
    {
        updated = NO;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc topViewController];
            updated = YES;
        }
        
        if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
            updated = YES;
        }
    }
    
    return vc;
}

- (UIColor *)currentBackgroundColor
{
    UIViewController *topVC = [self topViewController];
    
    if ([topVC respondsToSelector:@selector(popoverControllerBackgroundColor:)])
        return [(id <SYPopoverContentViewDelegate>)topVC popoverControllerBackgroundColor:self];
    
    return self.backgroundView.backgroundColor;
}

- (BOOL)shouldDismissOnBackgroundTap
{
    UIViewController *topVC = [self topViewController];
    
    if ([topVC respondsToSelector:@selector(popoverControllerShouldDismissOnBackgroundTap:)])
        return [(id <SYPopoverContentViewDelegate>)topVC popoverControllerShouldDismissOnBackgroundTap:self];
    
    return YES;
}

- (void)updateAppearance
{
    [self.backgroundView setBackgroundColor:[self currentBackgroundColor]];
    [self.backgroundView setFrame:self.containerView.bounds];
    [self.presentedView setFrame:[self frameOfPresentedViewInContainerView]];
    [self.presentedView setClipsToBounds:YES];
    
    if ([self.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nc = (UINavigationController *)self.presentedViewController;
        [nc.topViewController.view setFrame:self.presentedView.bounds];
        [nc.topViewController.view layoutIfNeeded];
    }
}

#pragma mark - Presentation

- (void)presentationTransitionWillBegin
{
    [super presentationTransitionWillBegin];
    
    [self.backgroundView setAlpha:0.];
    [self.containerView insertSubview:self.backgroundView atIndex:0];

    [self updateAppearance];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.backgroundView setAlpha:1.];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // [self updateAppearance];
    }];
    
    if ([self.popoverDelegate respondsToSelector:@selector(popoverControllerWillPresent:)])
        [self.popoverDelegate popoverControllerWillPresent:self];
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];
    if ([self.popoverDelegate respondsToSelector:@selector(popoverControllerWillDismiss:)])
        [self.popoverDelegate popoverControllerWillDismiss:self];
}

#pragma mark - UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    // update the size of the VC about to be opened to match the current VC size, allowing a smooth animation
    // between the two sizes
    [toVC.view setFrame:self.presentedView.bounds];
    [toVC.view layoutIfNeeded];
    
    SYPopoverNavigationTransition *transition = [[SYPopoverNavigationTransition alloc] initForOperation:operation];
    [transition setAdditionalAnimationBlock:^{
        // update the presented controller to the final size, needed for the animation
        [self updateAppearance];
    }];
    return transition;
}

@end

@implementation UIViewController (SYPopoverController)

- (void)sy_presentPopover:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^)(void))completion
{
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [viewController setTransitioningDelegate:[SYPopoverTransitioningDelegate shared]];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
