//
//  SYAppDelegate.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYAppDelegate.h"
#import "NSString+SY.h"
#import "SYKickAPI.h"
#import "SYMainVC.h"
#import "SYWindow.h"
#import "SYBonjourClient.h"

NSString *const UIAppDidOpenURLNotification              = @"UIAppDidOpenURLNotification";
NSString *const UIAppDidOpenURLNotification_AppIDKey     = @"UIAppDidOpenURLNotification_AppIDKey";
NSString *const UIAppDidOpenURLNotification_MagnetURLKey = @"UIAppDidOpenURLNotification_MagnetURLKey";

NSString *const NSTorrentAddedSuccessfully = @"kNSTorrentAddedSuccessfully";

@implementation SYAppDelegate

+ (SYAppDelegate *)obtain
{
    return (SYAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SYBonjourClient shared] start];
    
    SYMainVC *mainVC = [[SYMainVC alloc] init];
    SYNavigationController *nc = [[SYNavigationController alloc] initWithRootViewController:mainVC];
    self.window = [SYWindow mainWindowWithRootViewController:nc];
    
    return YES;
}
							
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //if (IOS_VER_GREATER_OR_EQUAL(@"9.0"))
    [[NSNotificationCenter defaultCenter] postNotificationName:UIAppDidOpenURLNotification
                                                        object:nil
                                                      userInfo:@{UIAppDidOpenURLNotification_AppIDKey:sourceApplication,
                                                                 UIAppDidOpenURLNotification_MagnetURLKey:url}];
    return YES;
}

- (void)openApp:(SYApp)app
{
    [[UIApplication sharedApplication] openURL:NSURLToLaunchSYApp(app)];
}

@end
