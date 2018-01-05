//
//  SYWebVC.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 11/06/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "SYWebVC.h"
#import "SYComputerModel.h"
#import "NSURLRequest+SY.h"

@interface SYWebVC () <WKNavigationDelegate, NSURLConnectionDelegate>
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinView;
@property (strong, nonatomic) UIBarButtonItem *buttonClose;
@end

@implementation SYWebVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    [[self.webView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor] setActive:YES];
    [[self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
    [[self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];

    self.buttonClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(buttonCloseTap:)];
    [self.navigationItem setLeftBarButtonItem:self.buttonClose];

    self.spinView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinView.hidesWhenStopped = YES;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.spinView]];
    
    self.webView.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:self.computer.name];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.computer.webURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30];
    [request setComputerID:self.computer.identifier];
    [self.webView loadRequest:request];
}

- (void)buttonCloseTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate methods

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.spinView startAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.spinView stopAnimating];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self.spinView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.spinView stopAnimating];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
