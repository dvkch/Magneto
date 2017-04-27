//
//  SYPopoverTransitions.m
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import "SYPopoverTransitions.h"

@implementation SYPopoverPresentationTransition

- (instancetype)initForPresenting:(BOOL)presenting
{
    self = [super init];
    if (self)
    {
        self.transitionDuration = 0.3f;
        self.presenting = presenting;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *inView = transitionContext.containerView;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    if(self.presenting)
    {
        [inView addSubview:to.view];
        
        // needed or iOS7 in landscape will be fucked up
        [to.view setFrame:inView.bounds];
        
        from.view.userInteractionEnabled = NO;
        to.view.userInteractionEnabled = NO;
        
        to.view.alpha = 0.0;
        CGAffineTransform t = to.view.transform;
        to.view.transform = CGAffineTransformScale(t, 1.2f, 1.2f);
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             to.view.alpha = 1.0;
                             to.view.transform = t;
                         } completion:^(BOOL finished) {
                             from.view.userInteractionEnabled = YES;
                             to.view.userInteractionEnabled = YES;
                             [transitionContext completeTransition:YES];
                         }];
    }
    else
    {
        [inView addSubview:to.view];
        [inView addSubview:from.view];
        
        from.view.userInteractionEnabled = NO;
        to.view.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             from.view.alpha = 0.0;
                             from.view.transform = CGAffineTransformScale(from.view.transform, 1.2f, 1.2f);
                         } completion:^(BOOL finished) {
                             from.view.transform = CGAffineTransformIdentity;
                             from.view.userInteractionEnabled = YES;
                             to.view.userInteractionEnabled = YES;
                             [transitionContext completeTransition:YES];
                             
                             // http://openradar.appspot.com/radar?id=5320103646199808
                             [[UIApplication sharedApplication].keyWindow addSubview:to.view];
                         }];
    }
}

@end



@implementation SYPopoverNavigationTransition

- (instancetype)initForOperation:(UINavigationControllerOperation)operation
{
    if (operation == UINavigationControllerOperationNone)
        return nil;
    
    self = [super init];
    if (self)
    {
        self.transitionDuration = .3f;
        self.operation = operation;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BOOL isPush = (self.operation == UINavigationControllerOperationPush);
    
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *toView   = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *inView   = [transitionContext containerView];
    inView.backgroundColor = toView.backgroundColor;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGAffineTransform translateFullRight = CGAffineTransformMakeTranslation( inView.bounds.size.width,      0);
    CGAffineTransform translateHalfLeft  = CGAffineTransformMakeTranslation(-inView.bounds.size.width / 2., 0);
    
    if (isPush)
    {
        [inView addSubview:toView];
        
        toView.transform = translateFullRight;
        fromView.transform = CGAffineTransformIdentity;
    }
    else
    {
        [inView insertSubview:toView belowSubview:fromView];
        
        toView.transform = translateHalfLeft;
        fromView.transform = CGAffineTransformIdentity;
    }
    
    [toView layoutIfNeeded];
    [fromView layoutIfNeeded];
    
    [UIView animateWithDuration:duration
                          delay:0.f
                        options:(UIViewAnimationOptionLayoutSubviews)
                     animations:^
    {
        if (isPush)
        {
            toView.transform    = CGAffineTransformIdentity;
            fromView.transform  = translateHalfLeft;
        }
        else
        {
            toView.transform    = CGAffineTransformIdentity;
            fromView.transform  = translateFullRight;
            fromView.alpha      = 0.;
        }
        
        if (self.additionalAnimationBlock)
            self.additionalAnimationBlock();
        
        // forces navigationBar items to reposition. shows some log because the "state" ivar is modified
        // inside the animation. restoring it after these call doesn't work and actually leaves the
        // navigation bar in a broken state. this has been tested on iOS 8.4 and 10.3 and looks good
        {
            UINavigationBar *nb = toVC.navigationController.navigationBar;
            [nb setValue:@(NO)  forKey:[@[@"loc", @"ked"] componentsJoinedByString:@""]];
            [nb setItems:nb.items.copy animated:NO];
            [nb setValue:@(YES) forKey:[@[@"loc", @"ked"] componentsJoinedByString:@""]];
        }
        
    } completion:^(BOOL finished)
    {
        toView.transform    = CGAffineTransformIdentity;
        fromView.transform  = CGAffineTransformIdentity;
        fromView.alpha      = 1.;
        
        if ([transitionContext transitionWasCancelled])
            [toView removeFromSuperview];
        else
            [fromView removeFromSuperview];
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        if (self.completionBlock)
            self.completionBlock();
    }];
}

@end
