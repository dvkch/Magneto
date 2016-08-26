//
//  SYPopoverNavigationController.h
//  SYPopover
//
//  Created by Stanislas Chevallier on 04/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SYPopoverTypeMenu,
    SYPopoverTypeDuring,
    SYPopoverTypeOptions,
} SYPopoverType;

@class SYPopoverNavigationController;
@class SYPopoverViewController;

@protocol SYPopoverNavigationControllerDelegate <NSObject>
- (BOOL)popoverNavigationControllerShouldDismiss:(SYPopoverNavigationController *)popoverNavigationController;
- (void)popoverNavigationControllerWillDismiss:(SYPopoverNavigationController *)popoverNavigationController animated:(BOOL)animated;
- (void)popoverNavigationControllerWillPresent:(SYPopoverNavigationController *)popoverNavigationController animated:(BOOL)animated;
@end

@interface SYPopoverNavigationController : UINavigationController
@property (nonatomic, weak) id<SYPopoverNavigationControllerDelegate> popoverDelegate;
@property (nonatomic, assign) UIColor *backgroundsColor;
- (instancetype)initWithRootViewController:(SYPopoverViewController *)rootViewController;
- (void)presentAsPopoverFromViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)close;
@end

