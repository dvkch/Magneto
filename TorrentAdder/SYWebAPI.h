//
//  SYWebAPI.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 23/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYResultModel : NSObject
@property (nonatomic, strong) NSString   *name;
@property (nonatomic, strong) NSString   *size;
@property (nonatomic, strong) NSString   *age;
@property (nonatomic, assign) BOOL       verified;
@property (nonatomic, assign) NSUInteger seed;
@property (nonatomic, assign) NSUInteger leech;
- (NSURL *)fullURL;
@end


@interface SYWebAPI : NSObject

+ (SYWebAPI *)shared;

- (void)findMirrorWithCompletionBlock:(void(^)(NSError *error))block;
- (void)lookFor:(NSString *)term withCompletionBlock:(void(^)(NSArray<SYResultModel *> *items, NSError *error))block;
- (void)getMagnetForResult:(SYResultModel *)result andCompletionBlock:(void(^)(NSString *magnet, NSError *error))block;

@end
