//
//  NSString+SYApp.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 10/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSString+SYApp.h"

NSURL *NSURLToLaunchSYApp(SYApp app)
{
    NSString *selfClosingWebpage = @"rawgit.com/dvkch/TorrentAdder/master/self_closing_page.html";
    NSString *urlToOpen = nil;
    switch (app)
    {
        case SYAppSafari:   urlToOpen = @"https://";      break; // opens new page
        case SYAppMail:     urlToOpen = @"mailto:";       break; // opens empty composer
        case SYAppSMS:      urlToOpen = @"sms:";          break; // opens empty composer
        case SYAppChrome:   urlToOpen = @"googlechrome:"; break; // OK
        case SYAppDolphin:  urlToOpen = @"dolphin:";      break; // OK
        case SYAppOpera:    urlToOpen = @"ohttps://";     break; // opens new page
        case SYAppMailbox:  urlToOpen = @"dbx-mailbox:";  break; // OK
        default: break;
    }
    
    if(app == SYAppSafari || app == SYAppOpera)
        urlToOpen = [urlToOpen stringByAppendingString:selfClosingWebpage];
    
    return [NSURL URLWithString:urlToOpen];
}

@implementation NSString (SYApp)

- (SYApp)parsedSYApp
{
    if ([self isEqualToStringNoCase:@"com.apple.mobilesafari"])
        return SYAppSafari;
    if ([self isEqualToStringNoCase:@"com.apple.mobilemail"])
        return SYAppMail;
    if ([self isEqualToStringNoCase:@"com.apple.mobilesms"])
        return SYAppSMS;
    if ([self isEqualToStringNoCase:@"com.google.chrome.ios"])
        return SYAppChrome;
    if ([self isEqualToStringNoCase:@"com.dolphin.browser.iphone"])
        return SYAppDolphin;
    if ([self isEqualToStringNoCase:@"com.opera.OperaMini"])
        return SYAppOpera;
    if ([self isEqualToStringNoCase:@"com.orchestra.v2"])
        return SYAppMailbox;
    
    NSLog(@"Unknown app: %@", self);
    return SYAppUnknown;
}

@end
