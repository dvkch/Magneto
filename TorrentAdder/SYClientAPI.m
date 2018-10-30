//
//  SYClientAPI.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYClientAPI.h"
#import "SYComputerModel.h"
#import "AFNetworking.h"
#import "XMLDictionary.h"

@interface SYClientAPI ()
@property (nonatomic, strong) AFHTTPSessionManager *managerUTorrent;
@property (nonatomic, strong) AFHTTPSessionManager *managerTransmission;
@end

@implementation SYClientAPI

+ (SYClientAPI *)shared
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.managerTransmission = [[AFHTTPSessionManager alloc] init];
        [self.managerTransmission setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [self.managerTransmission setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self.managerTransmission.requestSerializer setTimeoutInterval:10];
        
        self.managerUTorrent = [[AFHTTPSessionManager alloc] init];
        [self.managerUTorrent setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self.managerUTorrent setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [self.managerUTorrent.requestSerializer setTimeoutInterval:10];
    }
    return self;
}

#pragma mark - Public methods

- (void)addMagnet:(NSURL *)magnet
       toComputer:(SYComputerModel *)computer
       completion:(void(^)(NSString *message, NSError *error))block
{
    switch (computer.client) {
        case SYClientSoftware_uTorrent:
            [self addMagnet:magnet toUTorrentComputer:computer completion:block];
            break;
        case SYClientSoftware_Transmission:
            [self addMagnet:magnet toTransmissionComputer:computer sessionID:nil completion:block];
            break;
    }
}

// http://stackoverflow.com/questions/22079581/utorrent-api-add-url-giving-400-invalid-request
// http://forum.utorrent.com/topic/21814-web-ui-api/#entry207447
// http://forum.utorrent.com/topic/49588-%C2%B5torrent-webui/
- (void)addMagnet:(NSURL *)magnet toUTorrentComputer:(SYComputerModel *)computer completion:(void(^)(NSString *message, NSError *error))block
{
    void(^failureBock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        block(nil, error);
    };
    
    [self.managerUTorrent GET:[computer.apiURL.absoluteString stringByAppendingPathComponent:@"token.html"]
                   parameters:nil
                     progress:nil
                      success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithXMLData:responseObject];
        NSString *token = dic[@"div"][@"__text"];
        
        NSDictionary *parameters = @{@"token":token, @"action":@"add-url", @"s":magnet.absoluteString};
        
        [self.managerUTorrent GET:computer.apiURL.absoluteString
                       parameters:parameters
                         progress:nil
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
            block(nil, nil);
        } failure:failureBock];
    } failure:failureBock];
}

// https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
- (void)addMagnet:(NSURL *)magnet toTransmissionComputer:(SYComputerModel *)computer sessionID:(NSString *)sessionID completion:(void(^)(NSString *message, NSError *error))block
{
    NSDictionary *parameters = @{@"method"    : @"torrent-add",
                                 @"arguments" : @{@"filename":[magnet absoluteString]}};
    NSDictionary *headers;
    if (sessionID)
        headers = @{@"X-Transmission-Session-Id":sessionID};
    
    NSMutableURLRequest *request =
    [self.managerTransmission.requestSerializer requestWithMethod:@"POST"
                                                        URLString:computer.apiURL.absoluteString
                                                       parameters:parameters
                                                            error:nil];
    
    [request setTimeoutInterval:10];
    
    for (NSString *key in headers.allKeys)
        [request setValue:headers[key] forHTTPHeaderField:key];
    
    NSURLSessionDataTask *task =
    [self.managerTransmission dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError * error)
    {
        if (error)
        {
            if (((NSHTTPURLResponse *)response).statusCode == 409)
            {
                NSString *sessionID = ((NSHTTPURLResponse *)response).allHeaderFields[@"X-Transmission-Session-Id"];
                if (sessionID.length)
                {
                    [self addMagnet:magnet toTransmissionComputer:computer sessionID:sessionID completion:block];
                    return;
                }
            }
            block(nil, error);
        }
        else
        {
            block(responseObject[@"result"], nil);
        }
    }];
    
    [task resume];
}

@end
