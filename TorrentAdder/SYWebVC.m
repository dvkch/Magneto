//
//  SYWebVC.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 11/06/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYWebVC.h"
#import "SYComputerModel.h"
#import "JAHPAuthenticatingHTTPProtocol.h"
#import "UIAlertView+BlocksKit.h"

@interface SYWebVC () <UIWebViewDelegate, NSURLConnectionDelegate, JAHPAuthenticatingHTTPProtocolDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinView;
@property (strong, nonatomic) UIBarButtonItem *buttonClose;
@end

@implementation SYWebVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [JAHPAuthenticatingHTTPProtocol setDelegate:self];
    [JAHPAuthenticatingHTTPProtocol start];
    
    self.buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(buttonCloseTap:)];
    
    self.spinView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *buttonSpin = [[UIBarButtonItem alloc] initWithCustomView:self.spinView];
    
    [self.navigationItem setLeftBarButtonItem:self.buttonClose];
    [self.navigationItem setRightBarButtonItem:buttonSpin];
    
    [self.webView setDelegate:self];
    [self.spinView setHidesWhenStopped:YES];
}

- (void)dealloc
{
    [JAHPAuthenticatingHTTPProtocol stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:self.computer.name];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.computer.webURL]];
}

- (void)buttonCloseTap:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:self.computer.webURL.absoluteString])
    {
        [NSURLConnection connectionWithRequest:request delegate:self];
        return YES;
    }
    
    if ([request.URL.absoluteString isEqualToString:@"about:blank"])
        return YES;
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[self spinView] startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[self spinView] stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
    html = [html stringByReplacingOccurrencesOfString:@"{ERROR}" withString:error.localizedDescription];
}

#pragma mark - JAHPAuthenticatingHTTPProtocolDelegate methods

- (BOOL)authenticatingHTTPProtocol:(nonnull JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol canAuthenticateAgainstProtectionSpace:(nonnull NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
}

- (nullable JAHPDidCancelAuthenticationChallengeHandler)authenticatingHTTPProtocol:(nonnull JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol
                                                 didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Authentication needed"
                                                 message:@""
                                                delegate:nil
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil];
    
    [av bk_setCancelButtonWithTitle:@"Cancel" handler:^{
        [authenticatingHTTPProtocol cancelPendingAuthenticationChallenge];
    }];
    
    [av bk_addButtonWithTitle:@"Login" handler:^{
        NSURLCredential *credential = [NSURLCredential credentialWithUser:[av textFieldAtIndex:0].text
                                                                 password:[av textFieldAtIndex:1].text
                                                              persistence:NSURLCredentialPersistenceNone];
        [authenticatingHTTPProtocol resolvePendingAuthenticationChallengeWithCredential:credential];
    }];

    [av show];
    
    return ^(JAHPAuthenticatingHTTPProtocol * __nonnull authenticatingHTTPProtocol, NSURLAuthenticationChallenge * __nonnull challenge) {
        [av dismissWithClickedButtonIndex:av.cancelButtonIndex animated:YES];
    };
}

- (void)authenticatingHTTPProtocol:(nullable JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol logWithFormat:(nonnull NSString *)format
                         arguments:(va_list)arguments
{
    NSLog(@"%@", [[NSString alloc] initWithFormat:format arguments:arguments]);
}

@end
