//
//  SYWindow.m
//  TicTacDoh
//
//  Created by rominet on 12/12/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYWindow.h"

#define SLOW_ANIMATION_SPEED (0.05f)
@implementation SYWindow

+ (instancetype)mainWindowWithRootViewController:(UIViewController *)viewController
{
    SYWindow *window = [[SYWindow alloc] init];
    [window makeKeyAndVisible];
    
    // http://stackoverflow.com/questions/25963101/unexpected-nil-window-in-uiapplicationhandleeventfromqueueevent
    // The issue and solution described in the link above don't apply
    // for iOS 9+ screen spliting, an app started with a fraction of
    // the window would have the wrong frame.
    // Plus it seems that for previous verions of iOS it applies only
    // if you set the frame manually, if you don't set the frame at all
    // it should be okay.
    //[window setFrame:[[UIScreen mainScreen] bounds]];
    
    [window setRootViewController:viewController];
    [window setBackgroundColor:[UIColor whiteColor]];
    [window.layer setMasksToBounds:YES];
    [window.layer setOpaque:NO];
    return window;
}

- (void)toggleSlowAnimations
{
    if(self.layer.speed == 1) {
        NSLog(@"enabling slow animations");
        self.layer.speed = SLOW_ANIMATION_SPEED;
    }
    else {
        NSLog(@"disabling slow animations");
        self.layer.speed = 1;
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionEnded:motion withEvent:event];
#if DEBUG
    if (!self.preventSlowAnimationsOnShake)
        [self toggleSlowAnimations];
#endif
}

@end
