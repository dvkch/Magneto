//
//  SYAlertManager.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 30/09/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYComputerModel;

@interface SYAlertManager : NSObject

+ (void)showHelpMagnetAlertForComputer:(SYComputerModel *)computer;
+ (void)showMagnetAddedToComputer:(SYComputerModel *)computer
                      withMessage:(NSString *)computerMessage
                            error:(NSError *)error
                        backToApp:(BOOL)backToApp
                            block:(void(^)(BOOL backToApp))block;

+ (void)showNoComputerAlert;

@end
