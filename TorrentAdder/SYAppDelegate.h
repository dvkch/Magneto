//
//  SYAppDelegate.h
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SYAppSafari,
    SYAppMail,
    SYAppSMS,
    SYAppChrome,
    SYAppOpera,
    SYAppDolphin,
    SYAppMailbox,
    SYAppUnknown
} SYApp;

extern NSString *const UIAppDidOpenURL;
extern NSString *const NSTorrentAddedSuccessfully;

@interface SYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, atomic) NSURL *url;
@property (atomic) SYApp appUrlIsFromParsed;
@property (atomic) NSString * appUrlIsFrom;

+ (SYAppDelegate *)obtain;

- (void)openAppThatOpenedMe;
- (void)openApp:(SYApp)app;

@end

