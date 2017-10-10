//
//  SYPopoverController.m
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import "SYPopoverController.h"
#import <objc/runtime.h>

@interface SYPopoverController () <UINavigationControllerDelegate>
@property (nonatomic, strong, readwrite) UIView *backgroundView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
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
        
        UITapGestureRecognizer *tapOutside =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOutside:)];
        
        self.backgroundView = [[UIView alloc] init];
        [self.backgroundView addGestureRecognizer:tapOutside];
        
        self.visualEffectView = [[UIVisualEffectView alloc] init];
        
        // We registered for frame updates. This is needed to get the frame right when a modal VC
        // is being dismissed, or else the presentedViewController.view will be full size...
        // The view needs to be loaded before registering (we prevent warnings on iOS < 9 with setHidden:NO)
        [presentedViewController.view setHidden:NO];
        [presentedViewController addObserver:self forKeyPath:@"view.frame"
                                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                     context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.presentedViewController && [keyPath isEqualToString:@"view.frame"])
    {
        CGRect oldValue = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newValue = [change[NSKeyValueChangeNewKey] CGRectValue];
        if (!CGSizeEqualToSize(oldValue.size, newValue.size))
        {
            // we need to update the appearance async, or else the size is correct but not the origin...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateAppearance];
            });
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
    [self.presentedViewController removeObserver:self forKeyPath:@"view.frame"];
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
    [self.visualEffectView setEffect:self.backgroundVisualEffet];
    [self.visualEffectView setFrame:self.backgroundView.bounds];
    
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
    [self updateAppearance];
    id <UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    
    [self.containerView insertSubview:self.backgroundView atIndex:0];
    [self.backgroundView addSubview:self.visualEffectView];
    
    // on iOS 10+ animating the alpha of a UIVisualEffetView hides it
    // completely, we use the new UIViewPropertyAnimator to animate the
    // effect instead
    NSOperatingSystemVersion iOS10 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS10] && self.backgroundVisualEffet)
    {
        [self.backgroundView setAlpha:1.];
        [self.visualEffectView setEffect:nil];
        
        [[UIViewPropertyAnimator runningPropertyAnimatorWithDuration:coordinator.transitionDuration
                                                               delay:0
                                                             options:coordinator.completionCurve << 16
                                                          animations:^
        {
            [self.visualEffectView setEffect:self.backgroundVisualEffet];
        } completion:nil] startAnimation];
    }
    else
    {
        [self.backgroundView setAlpha:0.];
        [self.visualEffectView setEffect:self.backgroundVisualEffet];
    }
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id _) {
        [self.backgroundView setAlpha:1.];
    } completion:nil];
    
    if ([self.popoverDelegate respondsToSelector:@selector(popoverControllerWillPresent:)])
        [self.popoverDelegate popoverControllerWillPresent:self];
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];
    id <UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    
    // on iOS 10+ animating the alpha of a UIVisualEffetView hides it
    // completely, we use the new UIViewPropertyAnimator to animate the
    // effect instead
    NSOperatingSystemVersion iOS10 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS10] && self.backgroundVisualEffet)
    {
        [[UIViewPropertyAnimator runningPropertyAnimatorWithDuration:coordinator.transitionDuration
                                                               delay:0
                                                             options:coordinator.completionCurve << 16
                                                          animations:^
        {
            [self.visualEffectView setEffect:nil];
        } completion:nil] startAnimation];
    }
    else
    {
        [coordinator animateAlongsideTransition:^(id _) {
            [self.backgroundView setAlpha:0.];
        } completion:nil];
    }
    
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

- (void)sy_presentPopover:(UIViewController *)viewController
                 animated:(BOOL)animated
               completion:(void (^)(void))completion
{
    [self sy_presentPopover:viewController backgroundEffect:nil animated:animated completion:completion];
}

- (void)sy_presentPopover:(UIViewController *)viewController
         backgroundEffect:(UIVisualEffect *)backgroundEffect
                 animated:(BOOL)animated
               completion:(void (^)(void))completion
{
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [viewController setTransitioningDelegate:[SYPopoverTransitioningDelegate shared]];
    
    SYPopoverController *controller = (SYPopoverController *)viewController.presentationController;
    [controller setBackgroundVisualEffet:backgroundEffect];
    
    [self presentViewController:viewController animated:animated completion:nil];
}

@end
