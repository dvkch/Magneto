//
//  SYScreenHelper.h
//  SYKit
//
//  Created by Stanislas Chevallier on 24/02/15.
//  Copyright (c) 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *NSStringFromUIInterfaceOrientation(UIInterfaceOrientation o) __TVOS_PROHIBITED;

__TVOS_PROHIBITED
@interface SYScreenHelper : NSObject

+ (SYScreenHelper *)shared __TVOS_PROHIBITED;

@property (nonatomic, assign) BOOL showStatusBarOnIphoneLandscape __TVOS_PROHIBITED;

- (void)updateStatusBarVisibility:(UIInterfaceOrientation)orientation animated:(BOOL)animated __TVOS_PROHIBITED;

// has offset (origin.y != 0) on iOS >= 7
- (CGRect)screenRect:(UIInterfaceOrientation)orientation __TVOS_PROHIBITED;

 // ignores status bar
- (CGRect)fullScreenRect:(UIInterfaceOrientation)orientation __TVOS_PROHIBITED;

@end

