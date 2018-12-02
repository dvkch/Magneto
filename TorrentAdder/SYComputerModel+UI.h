//
//  SYComputerModel+UI.h
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYComputerModel.h"

typedef enum : NSInteger {
    SYComputerModelField_Name,
    SYComputerModelField_ClientSoftware,
    SYComputerModelField_Host,
    SYComputerModelField_Port,
    SYComputerModelField_Username,
    SYComputerModelField_Password,
} SYComputerModelField;

@interface SYComputerModel (UI)

+ (NSInteger)numberOfFields;
- (UIImage *)imageForField:(SYComputerModelField)field;
- (id)valueForField:(SYComputerModelField)field;
- (void)setValue:(id)value forField:(SYComputerModelField)field;
- (NSArray <NSString *> *)optionsForEnumField:(SYComputerModelField)field;
- (NSString *)nameForField:(SYComputerModelField)field;
- (UIKeyboardType)keyboardTypeForField:(SYComputerModelField)field;

@end
