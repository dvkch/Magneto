//
//  SYPopoverViewController.h
//  SYPopover
//
//  Created by Stanislas Chevallier on 26/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGSize const SYPopoverSizeSmall;
extern CGSize const SYPopoverSizeBig;

@class SYPopoverViewController;

@protocol SYPopoverViewControllerDelegate <NSObject>
- (BOOL)popoverViewControllerShouldDismiss:(SYPopoverViewController *)popoverViewController;
@end


@interface SYPopoverViewController : UIViewController

@property (nonatomic, strong) UIView *popoverView;
@property (nonatomic, weak) id<SYPopoverViewControllerDelegate> popoverDelegate;
@property (nonatomic, copy) CGSize(^popoverSizeBlock)(BOOL iPad, BOOL iPhoneSmallScreen);

- (void)close;
- (void)updateFramesAndAlphas;

@end
