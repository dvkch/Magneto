//
//  UIDevice+SYKit.m
//  SYKit
//
//  Created by Stanislas Chevallier on 07/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "UIDevice+SYKit.h"
#import <sys/utsname.h>

static NSDictionary *_syHardwareToModels;
static NSDictionary *_syModelNumberToModels;

@implementation UIDevice (SYKit)

+ (UIDeviceModel)deviceModelFromHardwareString:(NSString *)value
{
    if(!_syHardwareToModels)
    {
        _syHardwareToModels = @{// Simulator
                                @(UIDeviceModelSimulator32bits): @[@"i386"],
                                @(UIDeviceModelSimulator64bits): @[@"x86_64"],
                                
                                // iPod touch
                                @(UIDeviceModeliPodTouch1G): @[@"iPod1,1"],
                                @(UIDeviceModeliPodTouch2G): @[@"iPod2,1"],
                                @(UIDeviceModeliPodTouch3G): @[@"iPod3,1"],
                                @(UIDeviceModeliPodTouch4G): @[@"iPod4,1"],
                                @(UIDeviceModeliPodTouch5G): @[@"iPod5,1"],
                                
                                // iPad (9.7 inches)
                                @(UIDeviceModeliPad1):       @[@"iPad1,1"],
                                @(UIDeviceModeliPad2):       @[@"iPad2,1", @"iPad2,2", @"iPad2,3", @"iPad2,4"],
                                @(UIDeviceModeliPad3):       @[@"iPad3,1", @"iPad3,2", @"iPad3,3"],
                                @(UIDeviceModeliPad4):       @[@"iPad3,4", @"iPad3,5", @"iPad3,6"],
                                @(UIDeviceModeliPadAir):     @[@"iPad4,1", @"iPad4,2", @"iPad4,3"],
                                @(UIDeviceModeliPadAir2):    @[@"iPad5,3", @"iPad5,4"],
                                
                                // iPad mini
                                @(UIDeviceModeliPadMini):    @[@"iPad2,5", @"iPad2,6", @"iPad2,7"],
                                @(UIDeviceModeliPadMini2):   @[@"iPad4,4", @"iPad4,5"],
                                @(UIDeviceModeliPadMini3):   @[@"iPad4,7", @"iPad4,8", @"iPad4,9"],
                                
                                // iPhone
                                @(UIDeviceModeliPhone):      @[@"iPhone1,1"],
                                @(UIDeviceModeliPhone3G):    @[@"iPhone1,2"],
                                @(UIDeviceModeliPhone3GS):   @[@"iPhone2,1"],
                                @(UIDeviceModeliPhone4):     @[@"iPhone3,1", @"iPhone3,2", @"iPhone3,3"],
                                @(UIDeviceModeliPhone4S):    @[@"iPhone4,1"],
                                @(UIDeviceModeliPhone5):     @[@"iPhone5,1", @"iPhone5,2"],
                                @(UIDeviceModeliPhone5C):    @[@"iPhone5,3", @"iPhone5,4"],
                                @(UIDeviceModeliPhone5S):    @[@"iPhone6,1", @"iPhone6,2"],
                                @(UIDeviceModeliPhone6):     @[@"iPhone7,2"],
                                @(UIDeviceModeliPhone6Plus): @[@"iPhone7,1"],
                                
                                // AppleTV
                                @(UIDeviceModelAppleTV2Gen):     @[@"AppleTV2,1"],
                                @(UIDeviceModelAppleTV3Gen):     @[@"AppleTV3,1"],
                                @(UIDeviceModelAppleTV3GenRevA): @[@"AppleTV3,2"],
                                };
    }
    
    for(NSNumber *modelN in [_syHardwareToModels allKeys])
    {
        NSArray *hardwareStrings = _syHardwareToModels[modelN];
        for(NSString *hardwareString in hardwareStrings)
        {
            if([hardwareString isEqualToString:value])
                return [modelN unsignedIntegerValue];
        }
    }
    
    return UIDeviceModelUnknown;
}

+ (UIDeviceModel)deviceModelFromModelNumber:(NSString *)value
{
    if(!_syModelNumberToModels)
    {
        _syModelNumberToModels = @{// iPod touch
                                   @(UIDeviceModeliPodTouch1G): @[@"A1213"],
                                   @(UIDeviceModeliPodTouch2G): @[@"A1288"],
                                   @(UIDeviceModeliPodTouch3G): @[@"A1318"],
                                   @(UIDeviceModeliPodTouch4G): @[@"A1367"],
                                   @(UIDeviceModeliPodTouch5G): @[@"A1421"],
                                   
                                   // iPad (9.7 inches)
                                   @(UIDeviceModeliPad1):       @[@"A1219", @"A1337"],
                                   @(UIDeviceModeliPad2):       @[@"A1395", @"A1396", @"A1397"],
                                   @(UIDeviceModeliPad3):       @[@"A1416", @"A1430", @"A1403"],
                                   @(UIDeviceModeliPad4):       @[@"A1458", @"A1459", @"A1460"],
                                   @(UIDeviceModeliPadAir):     @[@"A1474", @"A1475", @"A1476"],
                                   @(UIDeviceModeliPadAir2):    @[@"A1566", @"A1567"],
                                   
                                   // iPad mini
                                   @(UIDeviceModeliPadMini):    @[@"A1432", @"A1454", @"A1455"],
                                   @(UIDeviceModeliPadMini2):   @[@"A1489", @"A1490", @"A1491"],
                                   @(UIDeviceModeliPadMini3):   @[@"A1599", @"A1600"],
                                   
                                   // iPhone
                                   @(UIDeviceModeliPhone):      @[@"A1203"],
                                   @(UIDeviceModeliPhone3G):    @[@"A1324", @"A1241"],
                                   @(UIDeviceModeliPhone3GS):   @[@"A1325", @"A1303"],
                                   @(UIDeviceModeliPhone4):     @[@"A1349", @"A1332"],
                                   @(UIDeviceModeliPhone4S):    @[@"A1431", @"A1387"],
                                   @(UIDeviceModeliPhone5):     @[@"A1428", @"A1429", @"A1442"],
                                   @(UIDeviceModeliPhone5C):    @[@"A1532", @"A1456", @"A1507", @"A1529"],
                                   @(UIDeviceModeliPhone5S):    @[@"A1533", @"A1453", @"A1457", @"A1530"],
                                   @(UIDeviceModeliPhone6):     @[@"A1549", @"A1586"],
                                   @(UIDeviceModeliPhone6Plus): @[@"A1522", @"A1524"],
                                   
                                   // AppleTV
                                   @(UIDeviceModelAppleTV2Gen):     @[@"A1378"],
                                   @(UIDeviceModelAppleTV3Gen):     @[@"A1427"],
                                   @(UIDeviceModelAppleTV3GenRevA): @[@"A1469"],
                                   };
    }
    
    for(NSNumber *modelN in [_syModelNumberToModels allKeys])
    {
        NSArray *modelNumbers = _syModelNumberToModels[modelN];
        for(NSString *modelNumber in modelNumbers)
        {
            if([modelNumber isEqualToString:value])
                return [modelN unsignedIntegerValue];
        }
    }
    
    return UIDeviceModelUnknown;
}

- (NSString*)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (UIDeviceModel)deviceModel
{
    return [[self class] deviceModelFromHardwareString:[self machineName]];
}

- (BOOL)shouldSupportViewBlur
{
    UIDeviceModel deviceModel = [self deviceModel];
    NSArray *noBlurModels = @[@(UIDeviceModeliPodTouch1G),  @(UIDeviceModeliPodTouch2G),
                              @(UIDeviceModeliPodTouch3G),  @(UIDeviceModeliPodTouch4G),
                              
                              @(UIDeviceModeliPhone),       @(UIDeviceModeliPhone3G),
                              @(UIDeviceModeliPhone3GS),    @(UIDeviceModeliPhone4),
                              @(UIDeviceModeliPhone4S),
                              
                              @(UIDeviceModeliPad1),        @(UIDeviceModeliPad3)];
    
    return ![noBlurModels containsObject:@(deviceModel)];
}


// the system version is cached because on older models it can take a relatively
// long time to retrieve
static NSString *_sySystemVersionCached;

- (NSString*)systemVersionCached
{
    if(!_sySystemVersionCached)
        _sySystemVersionCached = [self systemVersion];
    return _sySystemVersionCached;
}

- (BOOL)isIpad
{
    return [self userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (BOOL)iOSisEqualTo:(NSString *)version
{
    return [[self systemVersionCached] compare:version options:NSNumericSearch] == NSOrderedSame;
}

- (BOOL)iOSisGreaterThan:(NSString *)version
{
    return [[self systemVersionCached] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

- (BOOL)iOSisGreaterThanOrEqualTo:(NSString *)version
{
    return [[self systemVersionCached] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

- (BOOL)iOSisLessThan:(NSString *)version
{
    return [[self systemVersionCached] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

+ (BOOL)iOSis6Plus
{
    return [[self currentDevice] iOSisGreaterThanOrEqualTo:@"6.0"];
}

+ (BOOL)iOSis7Plus
{
    return [[self currentDevice] iOSisGreaterThanOrEqualTo:@"7.0"];
}

+ (BOOL)iOSis8Plus
{
    return [[self currentDevice] iOSisGreaterThanOrEqualTo:@"8.0"];
}

@end
