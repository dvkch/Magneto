//
//  UIImage+SY.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "UIImage+SY.h"

@implementation UIImage (SY)

- (UIImage *)imageMaskedWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self drawInRect:(CGRect){CGPointZero, self.size}];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, (CGRect){CGPointZero, self.size});
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
