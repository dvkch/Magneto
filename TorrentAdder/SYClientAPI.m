//
//  SYClientAPI.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYClientAPI.h"
#import "SYComputerModel.h"
#import <AFNetworking.h>

@interface SYClientAPI ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
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
        self.manager = [[AFHTTPRequestOperationManager alloc] init];
    }
    return self;
}

#pragma mark - Public methods

// https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
- (void)addMagnet:(NSURL *)magnet
       toComputer:(SYComputerModel *)computer
       completion:(void(^)(NSString *message, NSError *error))block
{
    [self addMagnet:magnet toComputer:computer sessionID:nil completion:block];
}

- (void)addMagnet:(NSURL *)magnet
       toComputer:(SYComputerModel *)computer
        sessionID:(NSString *)sessionID
       completion:(void(^)(NSString *message, NSError *error))block
{
    NSDictionary *parameters;
    NSDictionary *headers;
    
    switch (computer.client)
    {
        case SYClientSoftware_Transmission:
            parameters = @{@"method"    : @"torrent-add",
                           @"arguments" : @{@"filename":[magnet absoluteString]}};
            if (sessionID)
                headers = @{@"X-Transmission-Session-Id":sessionID};
            break;
        default:
            break;
    }

    NSMutableURLRequest *request =
    [self.manager.requestSerializer requestWithMethod:@"POST"
                                            URLString:computer.apiURL.absoluteString
                                           parameters:parameters
                                                error:nil];
    
    AFHTTPRequestOperation *operation =
    [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *message;
        switch (computer.client) {
            case SYClientSoftware_Transmission:
                message = responseObject[@"result"];
                break;
            default:
                break;
        }
        block(message, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 409)
        {
            [self addMagnet:magnet
                 toComputer:computer
                  sessionID:operation.response.allHeaderFields[@"X-Transmission-Session-Id"]
                 completion:block];
            return;
        }
        block(nil, error);
    }];
    
    [self.manager.operationQueue addOperation:operation];
}

@end
