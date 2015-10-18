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
@class SYResultModel;

@interface SYAddMagnetPopupVC : SYPopoverViewController

+ (void)showInViewController:(UIViewController *)viewController
                  withMagnet:(NSURL *)magnet
                    orResult:(SYResultModel *)result
               appToGoBackTo:(SYApp)appToGoBackTo;

@end
