//
//  UIView+Glow.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "UIView+Glow.h"

@implementation UIView (Glow)

-(void)addGlow:(UIColor*)color size:(CGFloat)size {
    if(!color)
        color = self.tintColor;
    
    self.layer.shadowColor = [color CGColor];
    self.layer.shadowRadius = size;
    self.layer.shadowOpacity = 1.;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

@end
