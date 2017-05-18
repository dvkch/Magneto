//
//  SYWebAPI.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 23/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYWebAPI.h"
#import "AFNetworking.h"
#import "UIWebView+BlocksKit.h"
#import <TFHpple.h>

@interface SYWebAPI ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSURL *mirrorURL;
@property (nonatomic, strong) NSMutableArray <NSURL *> *availableMirrorsURLs;
@end

@implementation SYWebAPI

+ (SYWebAPI *)shared
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
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://thepiratebay-proxylist.org/"]];
        [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self.manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    }
    return self;
}

- (void)setMirrorURL:(NSURL *)mirrorURL
{
    self->_mirrorURL = mirrorURL;
    
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:mirrorURL];
    [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [self.manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    NSLog(@"-> Using mirror: %@", self.mirrorURL);
}

- (BOOL)switchMirror
{
    if (self.mirrorURL)
        [self.availableMirrorsURLs removeObject:self.mirrorURL];
    
    if (!self.availableMirrorsURLs.count)
        return NO;
    
    NSUInteger maxURLIndex = MIN(self.availableMirrorsURLs.count, 3);
    [self setMirrorURL:self.availableMirrorsURLs[arc4random() % maxURLIndex]];
    return YES;
}

- (void)findMirrorWithCompletionBlock:(void(^)(NSError *error))block
{
    if (self.mirrorURL) {
        block(nil);
        return;
    }
    
    [self.manager GET:@""
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        TFHpple *result = [TFHpple hppleWithHTMLData:responseObject];
        NSArray <TFHppleElement *> *links = [result searchWithXPathQuery:@"//td[@title='URL']/a"];
        NSMutableArray <NSURL *> *urls = [NSMutableArray array];
        for (TFHppleElement *link in links) {
            NSURL *url = [NSURL URLWithString:[link objectForKey:@"href"]];
            if (url)
                [urls addObject:url];
        }
        
        if (urls.count)
        {
            self.availableMirrorsURLs = urls;
            [self switchMirror];

            block(nil);
        }
        else {
            block([NSError errorWithDomain:@"me.syan.TorrentAdded"
                                      code:1
                                  userInfo:@{NSLocalizedDescriptionKey:@"No mirror found"}]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.mirrorURL = nil;
        block(error);
    }];
}

- (void)lookFor:(NSString *)term
     completion:(void (^)(NSArray<SYResultModel *> *, NSError *))block
{
    if (!self.mirrorURL)
    {
        [self findMirrorWithCompletionBlock:^(NSError *error) {
            if (error)
                block(nil, error);
            else
                [self lookFor:term completion:block];
        }];
        return;
    }
    
    NSString *escapedTerm = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager GET:@"s/"
           parameters:@{@"q":escapedTerm, @"page":@(0), @"orderby":@(99)}
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSArray <SYResultModel *> *results =
        [SYResultModel resultsFromWebData:responseObject
                                  rootURL:self.manager.baseURL];
        
        block(results, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (((NSHTTPURLResponse *)task.response).statusCode == 404)
            block(@[], nil);
        else if (((NSHTTPURLResponse *)task.response).statusCode == 500)
        {
            if ([self switchMirror])
                [self lookFor:term completion:block];
            else
                block(nil, error);
        }
        else
            block(nil, error);
    }];
}

- (void)getMagnetForResult:(SYResultModel *)result
                completion:(void(^)(NSString *magnet, NSError *error))block
{
    if (result.magnet.length)
    {
        block(result.magnet, nil);
        return;
    }
    
    [self.manager GET:result.pageURL
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [result updateMagnetURLFromWebData:responseObject];
         block(result.magnet, nil);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         block(nil, error);
     }];
}

@end

