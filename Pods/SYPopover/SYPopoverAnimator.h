//
//  SYPopoverAnimator.h
//  SYPopover
//
//  Created by Stanislas Chevallier on 19/11/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPopoverAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, assign) BOOL presenting;

- (id)initForPresenting:(BOOL)presenting;

@end
