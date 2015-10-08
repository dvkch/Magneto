//
//  SYAddMagnetPopupVC.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 08/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYPopoverViewController.h"
#import "SYAppDelegate.h"

@class SYComputerModel;

@interface SYAddMagnetPopupVC : SYPopoverViewController

+ (void)showInViewController:(UIViewController *)viewController
                  withMagnet:(NSURL *)magnet
               appToGoBackTo:(SYApp)appToGoBackTo;

@end
