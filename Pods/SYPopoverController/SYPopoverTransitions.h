//
//  SYPopoverTransitions.h
//  SYPopover
//
//  Created by Stanislas Chevallier on 06/11/2016.
//  Copyright © 2016 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPopoverPresentationTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, assign) BOOL presenting;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initForPresenting:(BOOL)presenting NS_DESIGNATED_INITIALIZER;

@end

@interface SYPopoverNavigationTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, copy) void(^additionalAnimationBlock)(void);
@property (nonatomic, copy) void(^completionBlock)(void);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initForOperation:(UINavigationControllerOperation)operation NS_DESIGNATED_INITIALIZER;

@end

