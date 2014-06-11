//
//  SYWebVC.h
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 11/06/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYComputerModel;

@interface SYWebVC : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationBar *titleBar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (strong, nonatomic) SYComputerModel* computer;

@end
