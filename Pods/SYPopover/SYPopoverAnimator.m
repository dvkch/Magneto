//
//  SYPopoverAnimator.m
//  TicTacDoh
//
//  Created by Stanislas Chevallier on 19/11/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYPopoverAnimator.h"

@implementation SYPopoverAnimator

- (id)init
{
    self = [super init];
    if (self) {
        self.transitionDuration = 0.3f;
        self.presenting = YES;
    }
    return self;
}

- (id)initForPresenting:(BOOL)presenting
{
    self = [self init];
    if (self) {
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
