//
//  SYResultModel.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 24/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYResultModel.h"

@implementation SYResultModel

+ (NSArray *)arrayWithArrayOfDictionaries:(NSArray *)array
{
    NSMutableArray *objects = [NSMutableArray array];
    for (NSDictionary *dic in array)
        [objects addObject:[[self alloc] initWithDictionary:dic]];
    return [objects copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.name   = [dictionary[@"name"]   parsedString];
        self.magnet = [dictionary[@"magnet"] parsedString];
        self.size   = [dictionary[@"size"]   parsedString];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@, %@, %@>",
            [self class],
            self,
            [self.name   stringWithLimit:10],
            [self.magnet stringWithLimit:20],
            self.size];
}

@end
