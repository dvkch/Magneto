//
//  SYWebVC.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 11/06/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYWebVC.h"
#import "SYComputerModel.h"
#import "NSURLRequest+SY.h"

@interface SYWebVC () <UIWebViewDelegate, NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinView;
@property (strong, nonatomic) UIBarButtonItem *buttonClose;
@end

@implementation SYWebVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(buttonCloseTap:)];
    
    self.spinView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *buttonSpin = [[UIBarButtonItem alloc] initWithCustomView:self.spinView];
    
    [self.navigationItem setLeftBarButtonItem:self.buttonClose];
    [self.navigationItem setRightBarButtonItem:buttonSpin];
    
    [self.webView setDelegate:self];
    [self.spinView setHidesWhenStopped:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:self.computer.name];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.computer.webURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30];
    [request setComputerID:self.computer.identifier];
    [self.webView loadRequest:request];
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
    [webView loadHTMLString:html baseURL:nil];
}

@end
