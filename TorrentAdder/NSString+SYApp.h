//
//  NSString+SYApp.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 10/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

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

NSURL *NSURLToLaunchSYApp(SYApp app);

@interface NSString (SYApp)

- (SYApp)parsedSYApp;

@end
