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
        self.magnet = [NSURL URLWithString:[dictionary[@"magnet"] parsedString]];
        self.size   = [dictionary[@"size"]   parsedString];
        self.age    = [dictionary[@"age"]    parsedString];
        self.seed   = [dictionary[@"seed"]   parsedString];
        self.leech  = [dictionary[@"leech"]  parsedString];
        
        self.name = [self.name stringByReplacingOccurrencesOfString:@"\u00A0" withString:@" "];
        self.size = [self.size stringByReplacingOccurrencesOfString:@"\u00A0" withString:@" "];
        self.age  = [self.age  stringByReplacingOccurrencesOfString:@"\u00A0" withString:@" "];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@, %@, %@, %@, %@/%@>",
            [self class],
            self,
            [self.name stringWithLimit:10],
            [self.magnet.absoluteString stringWithLimit:20],
            self.size,
            self.age,
            self.seed,
            self.leech];
}

@end
