//
//  SYDatabase.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYDatabase.h"
#import "SYComputerModel.h"
#import <YapDatabase.h>

NSString * const SYDatabaseTableComputers = @"computers";

@interface SYDatabase ()
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *connection;
@end

@implementation SYDatabase

+ (SYDatabase *)shared
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbPath = [paths.firstObject stringByAppendingPathComponent:@"db.db"];
        
        self.database = [[YapDatabase alloc] initWithPath:dbPath];
        self.connection = [self.database newConnection];
    }
    return self;
}

- (NSArray *)computers
{
    NSMutableArray *objects = [NSMutableArray array];
    [self.connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [transaction enumerateKeysAndObjectsInCollection:SYDatabaseTableComputers
                                              usingBlock:^(NSString * _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop)
        {
            [objects addObject:object];
        }];
    }];
    return [objects copy];
}

- (SYComputerModel *)computerWithID:(NSString *)identifier
{
    __block SYComputerModel *object;
    [self.connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        object = [transaction objectForKey:identifier inCollection:SYDatabaseTableComputers];
    }];
    return object;
}

- (void)addComputer:(SYComputerModel *)computer
{
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction setObject:computer forKey:computer.identifier inCollection:SYDatabaseTableComputers];
    }];
}

- (void)removeComputer:(SYComputerModel *)computer
{
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction removeObjectForKey:computer.identifier inCollection:SYDatabaseTableComputers];
    }];
}

@end
