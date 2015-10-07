//
//  UIDevice+SYKit.h
//  SYKit
//
//  Created by Stanislas Chevallier on 07/07/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIDeviceModelUnknown,
    UIDeviceModelSimulator32bits,
    UIDeviceModelSimulator64bits,
    UIDeviceModeliPodTouch1G,
    UIDeviceModeliPodTouch2G,
    UIDeviceModeliPodTouch3G,
    UIDeviceModeliPodTouch4G,
    UIDeviceModeliPodTouch5G,
    UIDeviceModeliPhone,
    UIDeviceModeliPhone3G,
    UIDeviceModeliPhone3GS,
    UIDeviceModeliPhone4,
    UIDeviceModeliPhone4S,
    UIDeviceModeliPhone5,
    UIDeviceModeliPhone5C,
    UIDeviceModeliPhone5S,
    UIDeviceModeliPhone6,
    UIDeviceModeliPhone6Plus,
    UIDeviceModeliPad1,
    UIDeviceModeliPad2,
    UIDeviceModeliPad3,
    UIDeviceModeliPad4,
    UIDeviceModeliPadAir,
    UIDeviceModeliPadAir2,
    UIDeviceModeliPadMini,
    UIDeviceModeliPadMini2,
    UIDeviceModeliPadMini3,
    UIDeviceModelAppleTV2Gen,
    UIDeviceModelAppleTV3Gen,
    UIDeviceModelAppleTV3GenRevA,
} UIDeviceModel;


@interface UIDevice (SYKit)

+ (UIDeviceModel)deviceModelFromHardwareString:(NSString *)value;
+ (UIDeviceModel)deviceModelFromModelNumber:(NSString *)value;
- (UIDeviceModel)deviceModel;

- (BOOL)shouldSupportViewBlur;
- (BOOL)isIpad;

- (NSString*)systemVersionCached;

- (BOOL)iOSisEqualTo:(NSString *)version;
- (BOOL)iOSisGreaterThan:(NSString *)version;
- (BOOL)iOSisGreaterThanOrEqualTo:(NSString *)version;
- (BOOL)iOSisLessThan:(NSString *)version;

+ (BOOL)iOSis6Plus;
+ (BOOL)iOSis7Plus;
+ (BOOL)iOSis8Plus;

@end
