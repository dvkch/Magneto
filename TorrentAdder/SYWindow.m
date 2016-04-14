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

+ (SYWindow *)mainWindowWithRootViewController:(UIViewController *)viewController
{
    SYWindow *window = [[SYWindow alloc] init];
    [window makeKeyAndVisible];
    
    // http://stackoverflow.com/questions/25963101/unexpected-nil-window-in-uiapplicationhandleeventfromqueueevent
    //[window setFrame:[[UIScreen mainScreen] bounds]];
    [window setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    
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
#if DEBUG
    [self toggleSlowAnimations];
#endif
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"-> %@", NSStringFromCGRect(frame));
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    NSLog(@"-> %@", NSStringFromCGRect(bounds));
}

@end
