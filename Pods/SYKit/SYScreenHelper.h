//
//  SYScreenHelper.h
//  SYKit
//
//  Created by Stanislas Chevallier on 24/02/15.
//  Copyright (c) 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *NSStringFromUIInterfaceOrientation(UIInterfaceOrientation o);

@interface SYScreenHelper : NSObject

+ (SYScreenHelper *)shared;

@property (nonatomic, assign) BOOL showStatusBarOnIphoneLandscape;

- (void)updateStatusBarVisibility:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
- (CGRect)screenRect:(UIInterfaceOrientation)orientation; // has offset (origin.y != 0) on iOS >= 7
- (CGRect)fullScreenRect:(UIInterfaceOrientation)orientation; // ignores status bar

@end
