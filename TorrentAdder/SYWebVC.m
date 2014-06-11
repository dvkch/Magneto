//
//  SYWebVC.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 11/06/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYWebVC.h"
#import "SYComputerModel.h"

@interface SYWebVC ()

@end

@implementation SYWebVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.webView setDelegate:self];
    [self.spinView setHidesWhenStopped:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSURL *url;
    if([self->_computer transmissionPortOpened])
        url = self->_computer.transmissionGuiURL;
    else if([self->_computer uTorrentPortOpened])
        url = self->_computer.uTorrentGuiURL;
    
    self.titleBar.topItem.title = self->_computer.name;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)closeButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url;
    if([self->_computer transmissionPortOpened])
        url = self->_computer.transmissionGuiURL;
    else if([self->_computer uTorrentPortOpened])
        url = self->_computer.uTorrentGuiURL;
    
    if([request.URL.description hasPrefix:url.description])
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
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"Close", nil] show];
}

@end
