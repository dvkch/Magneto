//
//  SYPopoverController.h
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYPopoverTransitioningDelegate.h"
#import "SYPopoverTransitions.h"

@class SYPopoverController;

@protocol SYPopoverControllerDelegate <NSObject>
@optional
- (void)popoverControllerWillDismiss:(SYPopoverController *)popoverController;
- (void)popoverControllerWillPresent:(SYPopoverController *)popoverController;
@end

@protocol SYPopoverContentViewDelegate <NSObject>
@optional
- (BOOL)popoverControllerShouldDismissOnBackgroundTap:(SYPopoverController *)popoverController;
- (UIColor *)popoverControllerBackgroundColor:(SYPopoverController *)popoverController;
@end

@interface SYPopoverController : UIPresentationController <UIAdaptivePresentationControllerDelegate>
@property (nonatomic, strong, readonly) UIView *backgroundView;
@end

@interface UIViewController (SYPopoverController)

- (void)sy_presentPopover:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^)(void))completion;

@end
