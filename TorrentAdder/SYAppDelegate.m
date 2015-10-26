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
#import "JAHPAuthenticatingHTTPProtocol.h"
#import "UIAlertView+BlocksKit.h"
#import "SYComputerModel.h"
#import "SYDatabase.h"
#import "NSURLRequest+SY.h"

NSString *const UIAppDidOpenURLNotification              = @"UIAppDidOpenURLNotification";
NSString *const UIAppDidOpenURLNotification_AppIDKey     = @"UIAppDidOpenURLNotification_AppIDKey";
NSString *const UIAppDidOpenURLNotification_MagnetURLKey = @"UIAppDidOpenURLNotification_MagnetURLKey";

NSString *const NSTorrentAddedSuccessfully = @"kNSTorrentAddedSuccessfully";

@interface SYAppDelegate () <JAHPAuthenticatingHTTPProtocolDelegate>
@property (nonatomic, assign) BOOL showingAuthAlertView;
@end

@implementation SYAppDelegate

+ (SYAppDelegate *)obtain
{
    return (SYAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SYBonjourClient shared] start];

    [JAHPAuthenticatingHTTPProtocol setDelegate:self];
    [JAHPAuthenticatingHTTPProtocol start];
    
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

#pragma mark - Public methods

- (void)openApp:(SYApp)app
{
    [[UIApplication sharedApplication] openURL:NSURLToLaunchSYApp(app)];
}

#pragma mark - NSURL Auth support

#pragma mark - JAHPAuthenticatingHTTPProtocolDelegate methods

- (BOOL)authenticatingHTTPProtocol:(nonnull JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol canAuthenticateAgainstProtectionSpace:(nonnull NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
}

- (nullable JAHPDidCancelAuthenticationChallengeHandler)authenticatingHTTPProtocol:(nonnull JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol
                                                 didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge
{
    NSString *computerID;
    if ([authenticatingHTTPProtocol.request isKindOfClass:[NSMutableURLRequest class]])
        computerID = [(NSMutableURLRequest *)authenticatingHTTPProtocol.request computerID];
    
    SYComputerModel *computer = [[SYDatabase shared] computerWithID:computerID];
    
    if (!computer)
    {
        [authenticatingHTTPProtocol cancelPendingAuthenticationChallenge];
        return nil;
    }
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)authenticatingHTTPProtocol.request;
    request.numberOfAuthTries += 1;
    
    if (request.numberOfAuthTries < 2)
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:computer.username
                                                                 password:computer.password
                                                              persistence:NSURLCredentialPersistenceForSession];
        [authenticatingHTTPProtocol resolvePendingAuthenticationChallengeWithCredential:credential];
        return nil;
    }
    
    if (self.showingAuthAlertView)
    {
        [authenticatingHTTPProtocol cancelPendingAuthenticationChallenge];
        return nil;
    }
    
    __block BOOL canceled = NO;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Authentication needed"
                                                 message:[NSString stringWithFormat:@"%@ requires a user and a password", computer.name]
                                                delegate:nil
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil];
    
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    [av bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        [self setShowingAuthAlertView:NO];
        if (canceled)
            return;
        [authenticatingHTTPProtocol cancelPendingAuthenticationChallenge];
    }];
    
    [av bk_addButtonWithTitle:@"Login" handler:^{
        [computer setUsername:[av textFieldAtIndex:0].text];
        [computer setPassword:[av textFieldAtIndex:1].text];
        [[SYDatabase shared] addComputer:computer];

        [self setShowingAuthAlertView:NO];
        
        if (canceled)
            return;
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:computer.username
                                                                 password:computer.password
                                                              persistence:NSURLCredentialPersistenceForSession];
        [authenticatingHTTPProtocol resolvePendingAuthenticationChallengeWithCredential:credential];
    }];
    
    [self setShowingAuthAlertView:YES];
    [av show];
    
    return ^(JAHPAuthenticatingHTTPProtocol * __nonnull authenticatingHTTPProtocol, NSURLAuthenticationChallenge * __nonnull challenge) {
        canceled = YES;
    };
}

/*
- (void)authenticatingHTTPProtocol:(nullable JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol logWithFormat:(nonnull NSString *)format
                         arguments:(va_list)arguments
{
    NSLog(@"%@", [[NSString alloc] initWithFormat:format arguments:arguments]);
}
*/

@end
