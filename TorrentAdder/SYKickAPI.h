//
//  SYKickAPI.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 23/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYKickObject : NSObject
@property (nonatomic, strong) NSString   *name;
@property (nonatomic, strong) NSString   *magnet;
@property (nonatomic, assign) NSUInteger seed;
@property (nonatomic, assign) NSUInteger leech;
@end


@interface SYKickAPI : NSObject

+ (SYKickAPI *)shared;

- (void)lookFor:(NSString *)term withCompletionBlock:(void(^)(NSArray *items, NSError *error))block;

@end
