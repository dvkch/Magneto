//
//  SYAppDelegate.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+SYApp.h"

extern NSString *const UIAppDidOpenURLNotification;
extern NSString *const UIAppDidOpenURLNotification_AppIDKey;
extern NSString *const UIAppDidOpenURLNotification_MagnetURLKey;

extern NSString *const NSTorrentAddedSuccessfully;

@interface SYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (SYAppDelegate *)obtain;

- (void)openApp:(SYApp)app;

@end

