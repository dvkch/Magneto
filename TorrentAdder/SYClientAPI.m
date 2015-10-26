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
@property (nonatomic, strong) AFHTTPRequestOperationManager *managerUTorrent;
@property (nonatomic, strong) AFHTTPRequestOperationManager *managerTransmission;
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
        self.managerTransmission = [[AFHTTPRequestOperationManager alloc] init];
        [self.managerTransmission setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [self.managerTransmission setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        self.managerUTorrent = [[AFHTTPRequestOperationManager alloc] init];
        [self.managerUTorrent setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self.managerUTorrent setResponseSerializer:[AFHTTPResponseSerializer serializer]];
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
    void(^failureBock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    };
    
    [self.managerUTorrent GET:[computer.apiURL.absoluteString stringByAppendingPathComponent:@"token.html"]
                   parameters:nil
                      success:^(AFHTTPRequestOperation * _Nonnull op, id  _Nonnull responseObject)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithXMLData:op.responseData];
        NSString *token = dic[@"div"][@"__text"];
        
        NSDictionary *parameters = @{@"token":token, @"action":@"add-url", @"s":magnet.absoluteString};
        
        NSMutableURLRequest *request =
        [self.managerUTorrent.requestSerializer requestWithMethod:@"GET"
                                                        URLString:computer.apiURL.absoluteString
                                                       parameters:parameters
                                                            error:nil];
        
        [request setTimeoutInterval:10];
        
        AFHTTPRequestOperation *operation =
        [self.managerUTorrent HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:NULL];
            block(nil, nil);
        } failure:failureBock];
        
        [self.managerUTorrent.operationQueue addOperation:operation];
        
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
    
    AFHTTPRequestOperation *operation =
    [self.managerTransmission HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject[@"result"], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
    
    [self.managerTransmission.operationQueue addOperation:operation];}

@end
