//
//  SYDatabase.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 29/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYComputerModel;

@interface SYDatabase : NSObject

+ (SYDatabase *)shared;

- (NSArray *)computers;
- (SYComputerModel *)computerWithID:(NSString *)identifier;
- (void)addComputer:(SYComputerModel *)computer;
- (void)removeComputer:(SYComputerModel *)computer;

@end
