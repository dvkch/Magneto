//
//  UIScreen+SYKit.m
//  SYKit
//
//  Created by Stanislas Chevallier on 07/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "UIScreen+SYKit.h"
#import "UIDevice+SYKit.h"

@implementation UIScreen (SYKit)

- (CGRect)boundsFixedToPortraitOrientation
{
    if ([self respondsToSelector:@selector(fixedCoordinateSpace)])
    {
        return [self.coordinateSpace convertRect:self.bounds
                               toCoordinateSpace:self.fixedCoordinateSpace];
    }
    return self.bounds;
}

- (CGRect)screenRectForOrientation:(UIInterfaceOrientation)orientation
    showStatusBarOnIphoneLandscape:(BOOL)showStatusBarOnIphoneLandscape
           ignoreStatusBariOSOver7:(BOOL)ignoreStatusBariOSOver7
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    BOOL showStatusBar = [[UIDevice currentDevice] isIpad] || isPortrait || showStatusBarOnIphoneLandscape;
    
    CGFloat statusBarHeight = (showStatusBar ? 20 : 0);
    
    CGSize screenSize = [[UIScreen mainScreen] boundsFixedToPortraitOrientation].size;
    CGFloat viewWidth  = isPortrait ? screenSize.width  : screenSize.height;
    CGFloat viewHeight = isPortrait ? screenSize.height : screenSize.width;
    
    if (![UIDevice iOSis7Plus] || !ignoreStatusBariOSOver7)
        viewHeight -= statusBarHeight;
    
    return CGRectMake(0, (ignoreStatusBariOSOver7 ? 0 : statusBarHeight), viewWidth, viewHeight);
}

@end
