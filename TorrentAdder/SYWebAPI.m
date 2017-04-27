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


@interface SYResultModel ()
@property (nonatomic, strong) NSString   *magnet;
@property (nonatomic, strong) NSString   *pageURL;
@property (nonatomic, strong) NSURL      *rootURL;
@end

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

- (void)lookFor:(NSString *)term withCompletionBlock:(void (^)(NSArray<SYResultModel *> *, NSError *))block
{
    if (!self.mirrorURL)
    {
        [self findMirrorWithCompletionBlock:^(NSError *error) {
            if (error)
                block(nil, error);
            else
                [self lookFor:term withCompletionBlock:block];
        }];
        return;
    }
    
    NSString *escapedTerm = [term stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    [self.manager GET:@"s/"
           parameters:@{@"q":escapedTerm, @"page":@(0), @"orderby":@(99)}
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject)
    {
        //NSLog(@"-> \n%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        TFHpple *result = [TFHpple hppleWithHTMLData:responseObject];
        
        NSArray <TFHppleElement *> *rows = [result searchWithXPathQuery:@"//table[@id='searchResult']/tr"];
        if (!rows.count)
            rows = [result searchWithXPathQuery:@"//table[@id='searchResult']/tbody/tr"];
        
        NSMutableArray <SYResultModel *> *results = [NSMutableArray array];
        for (TFHppleElement *row in rows)
        {
            TFHppleElement *tdDetails = [row childrenWithTagName:@"td"][1];
            TFHppleElement *tdSE      = [row childrenWithTagName:@"td"][2];
            TFHppleElement *tdLE      = [row childrenWithTagName:@"td"][3];
            
            TFHppleElement *fontChild = [tdDetails firstChildWithTagName:@"font"];
            NSMutableString *dateSizeAndUser = [[fontChild text] mutableCopy];
            if ([fontChild firstChildWithTagName:@"b"])
                [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"b"] text]];
            
            if ([fontChild firstChildWithTagName:@"a"])
                [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"a"] text]];
            else
                [dateSizeAndUser appendString:[[fontChild firstChildWithTagName:@"i"] text]];
            
            NSArray <NSString *> *components = [dateSizeAndUser componentsSeparatedByString:@", "];
            NSString *date = components[0];
            date = [date stringByReplacingOccurrencesOfString:@"Uploaded " withString:@""];
            
            NSString *size = @"";
            if (components.count >= 2)
                size = [components[1] stringByReplacingOccurrencesOfString:@"Size " withString:@""];
            
            SYResultModel *result = [[SYResultModel alloc] init];
            result.name     = [[[tdDetails firstChildWithTagName:@"div"]
                                firstChildWithTagName:@"a"]
                               text];
            
            if (!result.name.length)
            {
                result.name     = [[[[tdDetails firstChildWithTagName:@"div"]
                                     firstChildWithTagName:@"a"]
                                    firstChildWithTagName:@"span"]
                                   text];
            }
            
            NSAssert(result.name.length, @"No name for result row");
            
            result.rootURL  = self.manager.baseURL;
            result.pageURL  = [[[tdDetails firstChildWithTagName:@"div"]
                                firstChildWithTagName:@"a"]
                               objectForKey:@"href"];
            result.seed     = [[tdSE text] integerValue];
            result.leech    = [[tdLE text] integerValue];
            result.verified = [[tdDetails raw] containsString:@"VIP"];
            result.age      = date;
            result.size     = size;
            
            [results addObject:result];
        }
        
        block(results, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (((NSHTTPURLResponse *)task.response).statusCode == 404)
            block(@[], nil);
        else if (((NSHTTPURLResponse *)task.response).statusCode == 500)
        {
            if ([self switchMirror])
                [self lookFor:term withCompletionBlock:block];
            else
                block(nil, error);
        }
        else
            block(nil, error);
    }];
}

- (void)getMagnetForResult:(SYResultModel *)result andCompletionBlock:(void(^)(NSString *magnet, NSError *error))block
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
         TFHpple *webobject = [TFHpple hppleWithHTMLData:responseObject];
         
         NSArray <TFHppleElement *> *links = [webobject searchWithXPathQuery:@"//div[@class='download']/a"];
         
         NSString *magnetURL = nil;
         for (TFHppleElement *link in links)
         {
             NSString *tempURL = [link objectForKey:@"href"];
             if ([tempURL hasPrefix:@"magnet:"])
             {
                 magnetURL = tempURL;
                 break;
             }
         }
         
         [result setMagnet:magnetURL];
         block(magnetURL, nil);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         block(nil, error);
     }];
}

@end

@implementation SYResultModel

- (NSURL *)fullURL
{
    return [NSURL URLWithString:self.pageURL relativeToURL:self.rootURL];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@ (%@, %@), %d/%d, verif: %d>",
            self.class,
            self,
            self.name,
            self.size,
            self.age,
            (int)self.seed,
            (int)self.leech,
            self.verified];
}

@end
