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
    
    CGFloat w = [self.text sizeWithFont:self.font].width + 6.f;
    
    CGFloat mLeft  = self.frame.origin.x;
    CGFloat mRight = self.superview.frame.size.width - self.frame.origin.x - self.frame.size.width;
    
    CGRect newFrame = self.frame;
    
    BOOL keepMarginLeft = ((self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) == 0);
    if(keepMarginLeft) {
        newFrame.size.width = w;
        newFrame.origin.x = mLeft;
    }
    else {
        newFrame.size.width = w;
        newFrame.origin.x = self.superview.frame.size.width - mRight - newFrame.size.width;
    }
    
    [self setFrame:newFrame];
}

@end
