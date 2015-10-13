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
    return 6;
}

- (UIImage *)imageForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return [UIImage imageNamed:@"form_bookmark"];
        case SYComputerModelField_ClientSoftware:
            return [UIImage imageNamed:@"form_cmd"];
        case SYComputerModelField_Host:
            return [UIImage imageNamed:@"form_host"];
        case SYComputerModelField_Port:
            return [UIImage imageNamed:@"form_port"];
        case SYComputerModelField_Username:
            return [UIImage imageNamed:@"form_user"];
        case SYComputerModelField_Password:
            return [UIImage imageNamed:@"form_pass"];
    }
}

- (id)valueForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return self.name;
        case SYComputerModelField_ClientSoftware:
            return @(self.client);
        case SYComputerModelField_Host:
            return self.host;
        case SYComputerModelField_Port:
            return self.port == 0 ? nil : [NSString stringWithFormat:@"%d", self.port];
        case SYComputerModelField_Username:
            return self.username;
        case SYComputerModelField_Password:
            return self.password;
    }
}

- (void)setValue:(id)value forField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            self.name = value;
            break;
        case SYComputerModelField_ClientSoftware:
            self.client = [value intValue];
            break;
        case SYComputerModelField_Host:
            self.host = value;
            break;
        case SYComputerModelField_Port:
            self.port = [value intValue];
            break;
        case SYComputerModelField_Username:
            self.username = value;
            break;
        case SYComputerModelField_Password:
            self.password = value;
            break;
    }
}

- (NSArray *)optionsForEnumField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return nil;
        case SYComputerModelField_ClientSoftware:
            return @[@"Transmission", @"uTorrent"];
        case SYComputerModelField_Host:
            return nil;
        case SYComputerModelField_Port:
            return nil;
        case SYComputerModelField_Username:
            return nil;
        case SYComputerModelField_Password:
            return nil;
    }
}

- (NSString *)nameForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return @"Name";
        case SYComputerModelField_ClientSoftware:
            return @"Software";
        case SYComputerModelField_Host:
            return @"Host";
        case SYComputerModelField_Port:
            return @"Port";
        case SYComputerModelField_Username:
            return @"Username";
        case SYComputerModelField_Password:
            return @"Password";
    }
}

- (UIKeyboardType)keyboardTypeForField:(SYComputerModelField)field
{
    switch (field) {
        case SYComputerModelField_Name:
            return UIKeyboardTypeDefault;
        case SYComputerModelField_ClientSoftware:
            return UIKeyboardTypeDefault;
        case SYComputerModelField_Host:
            return UIKeyboardTypeURL;
        case SYComputerModelField_Port:
            return UIKeyboardTypeNumberPad;
        case SYComputerModelField_Username:
            return UIKeyboardTypeDefault;
        case SYComputerModelField_Password:
            return UIKeyboardTypeDefault;
    }
}

@end
