//
//  SYResultModel.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 24/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYResultModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL    *magnet;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *seed;
@property (nonatomic, strong) NSString *leech;

+ (NSArray *)arrayWithArrayOfDictionaries:(NSArray *)array;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
