//
//  SYAppDelegate.m
//  TorrentAdder
//
//  Created by rominet on 19/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYAppDelegate.h"
#import "NSString+SY.h"
#import "SYWebAPI.h"
#import "SYMainVC.h"
#import "SYWindow.h"
#import "SYBonjourClient.h"
#import "JAHPAuthenticatingHTTPProtocol.h"
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
    [(SYWindow *)self.window setPreventSlowAnimationsOnShake:NO];
    
#if DEBUG_POPUP
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *magnet = @"magnet:?xt=urn:btih:0403fb4728bd788fbcb67e87d6feb241ef38c75a&dn=ubuntu-16.10-desktop-amd64.iso&tr=http%3A%2F%2Ftorrent.ubuntu.com%3A6969%2Fannounce&tr=http%3A%2F%2Fipv6.torrent.ubuntu.com%3A6969%2Fannounce";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIAppDidOpenURLNotification
                                                            object:nil
                                                          userInfo:@{UIAppDidOpenURLNotification_MagnetURLKey:[NSURL URLWithString:magnet]}];
    });
#endif
    
    return YES;
}
							
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authentication needed"
                                                                   message:[NSString stringWithFormat:@"%@ requires a user and a password", computer.name]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setShowingAuthAlertView:NO];
        if (canceled)
            return;
        [authenticatingHTTPProtocol cancelPendingAuthenticationChallenge];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [computer setUsername:alert.textFields.firstObject.text];
        [computer setPassword:alert.textFields.lastObject.text];
        [[SYDatabase shared] addComputer:computer];
        
        [self setShowingAuthAlertView:NO];
        
        if (canceled)
            return;
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:computer.username
                                                                 password:computer.password
                                                              persistence:NSURLCredentialPersistenceForSession];
        [authenticatingHTTPProtocol resolvePendingAuthenticationChallengeWithCredential:credential];
    }]];
    
    
    [self setShowingAuthAlertView:YES];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
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
