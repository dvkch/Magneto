//
//  SYComputerModel+UI.m
//  TorrentAdder
//
//  Created by Stan Chevallier on 05/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYComputerModel+UI.h"

@implementation SYComputerModel (UI)

+ (NSUInteger)numberOfFields
{
    return 4;
}

- (UIImage *)imageForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return [UIImage imageNamed:@"form_bookmark"];
        case SYComputerModelField_Host:
            return [UIImage imageNamed:@"form_host"];
        case SYComputerModelField_Port:
            return [UIImage imageNamed:@"form_port"];
        case SYComputerModelField_ClientSoftware:
            return [UIImage imageNamed:@"form_cmd"];
    }
}

- (id)valueForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return self.name;
        case SYComputerModelField_Host:
            return self.host;
        case SYComputerModelField_Port:
            return self.port == 0 ? nil : [NSString stringWithFormat:@"%d", self.port];
        case SYComputerModelField_ClientSoftware:
            return @(self.client);
    }
}

- (void)setValue:(id)value forField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            self.name = value;
            break;
        case SYComputerModelField_Host:
            self.host = value;
            break;
        case SYComputerModelField_Port:
            self.port = [value intValue];
            break;
        case SYComputerModelField_ClientSoftware:
            self.client = [value intValue];
            break;
    }
}

- (NSArray *)optionsForEnumField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return nil;
        case SYComputerModelField_Host:
            return nil;
        case SYComputerModelField_Port:
            return nil;
        case SYComputerModelField_ClientSoftware:
            return @[@"Transmission", @"uTorrent"];
    }
}

- (NSString *)nameForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return @"Name";
        case SYComputerModelField_Host:
            return @"Host";
        case SYComputerModelField_Port:
            return @"Port";
        case SYComputerModelField_ClientSoftware:
            return @"Software";
    }
}

- (UIKeyboardType)keyboardTypeForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return UIKeyboardTypeDefault;
        case SYComputerModelField_Host:
            return UIKeyboardTypeURL;
        case SYComputerModelField_Port:
            return UIKeyboardTypeNumberPad;
        case SYComputerModelField_ClientSoftware:
            return UIKeyboardTypeDefault;
    }
}

@end
