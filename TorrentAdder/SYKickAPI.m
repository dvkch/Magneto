//
//  SYKickAPI.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 23/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYKickAPI.h"
#import "AFNetworking.h"
#import "UIWebView+BlocksKit.h"
#import "SYResultModel.h"

@interface SYKickAPI ()
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *js;
@end

@implementation SYKickAPI

+ (SYKickAPI *)shared
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://kat.cr"]];
        [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self.manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        self.webView = [[UIWebView alloc] init];
        
        self.queue = dispatch_queue_create("SYKickAPI", 0);
        
        self.js = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"extract" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL];
    }
    return self;
}

- (void)lookFor:(NSString *)term withCompletionBlock:(void(^)(NSArray *items, NSError *error))block
{
    NSString *query = [term stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    [self.manager GET:[@"usearch/" stringByAppendingString:query]
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSData *responseObject)
    {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self.webView bk_setDidFinishLoadBlock:^(UIWebView *webView) {
            NSString *json = [webView stringByEvaluatingJavaScriptFromString:self.js];
            NSArray *dics = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                block([SYResultModel arrayWithArrayOfDictionaries:dics], nil);
            });
        }];
        [self.webView loadHTMLString:string baseURL:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 404)
            block(nil, nil);
        else
            block(nil, error);
    }];
}

@end
