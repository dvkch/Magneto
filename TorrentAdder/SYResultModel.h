//
//  SYResultModel.h
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/04/2017.
//  Copyright © 2017 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYResultModel : NSObject

@property (nonatomic, strong) NSString   *name;
@property (nonatomic, strong) NSString   *size;
@property (nonatomic, strong) NSString   *age;
@property (nonatomic, assign) BOOL       verified;
@property (nonatomic, assign) NSUInteger seed;
@property (nonatomic, assign) NSUInteger leech;
@property (nonatomic, strong) NSURL     *magnet;
@property (nonatomic, strong) NSString   *pageURL;
@property (nonatomic, strong) NSURL      *rootURL;

- (NSURL *)fullURL;
- (NSDate *)parsedDate;

+ (nonnull NSArray <SYResultModel *> *)resultsFromWebData:(NSData *)data rootURL:(NSURL *)rootURL;

- (void)updateMagnetURLFromWebData:(NSData *)data;

@end
