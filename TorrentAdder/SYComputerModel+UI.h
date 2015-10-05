//
//  SYComputerModel+UI.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYComputerModel.h"

typedef enum : NSUInteger {
    SYComputerModelField_Name,
    SYComputerModelField_Host,
    SYComputerModelField_Port,
    SYComputerModelField_ClientSoftware
} SYComputerModelField;

@interface SYComputerModel (UI)

+ (NSUInteger)numberOfFields;
- (UIImage *)imageForField:(SYComputerModelField)field;
- (id)valueForField:(SYComputerModelField)field;
- (void)setValue:(id)value forField:(SYComputerModelField)field;
- (NSArray *)optionsForEnumField:(SYComputerModelField)field;
- (NSString *)nameForField:(SYComputerModelField)field;
- (UIKeyboardType)keyboardTypeForField:(SYComputerModelField)field;

@end
