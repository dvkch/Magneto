//
//  SYLabelTag.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYLabelTag.h"
#import "UIView+Glow.h"

@implementation SYLabelTag

-(void)setText:(NSString *)text {
    [super setText:text];
    
    [self setTextColor:[UIColor blackColor]];
    [self addGlow:[UIColor whiteColor] size:4.f];
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
    [self.layer setCornerRadius:4.f];
    [self.layer setMasksToBounds:YES];
}

- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    s.width += 14;
    return s;
}

@end
