//
//  SYNavigationController.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYNavigationController.h"
#import "UIColor+SY.h"

@interface SYNavigationController ()

@end

@implementation SYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[UIColor lightBlueColor]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

@end
