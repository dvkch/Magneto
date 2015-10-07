//
//  UIImage+SYKit.h
//  PhoneBook
//
//  Created by rominet on 1/1/13.
//  Copyright (c) 2013 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SYKit)

- (UIImage *)imageByAddingPaddingTop:(CGFloat)top
                                left:(CGFloat)left
                               right:(CGFloat)right
                              bottom:(CGFloat)bottom;


- (UIImage *)imageResizedTo:(CGSize)size;
- (UIImage *)imageResizedSquarreTo:(CGFloat)size;
- (UIImage *)imageResizedHeightTo:(CGFloat)height;
- (UIImage *)imageResizedWidthTo:(CGFloat)width;

- (UIImage *)imageWithToolbarButtonStyling;
- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;
- (UIImage *)imageWithAngle:(CGFloat)angle;

@end
