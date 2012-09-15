//
//  UIDevice+Resolutions.m
//  Simple UIDevice Category for handling different iOSs hardware resolutions
//
//  Created by Daniele Margutti on 9/13/12.
//  web: http://www.danielemargutti.com
//  mail: daniele.margutti@gmail.com
//  Copyright (c) 2012 Daniele Margutti. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    UIDevice_iPhoneStandardRes      = 1,    // iPhone 1,3,3GS Standard Resolution   (320x480px)
    UIDevice_iPhoneHiRes            = 2,    // iPhone 4,4S High Resolution          (640x960px)
    UIDevice_iPhoneTallerHiRes      = 3,    // iPhone 5 High Resolution             (640x1136px)
    UIDevice_iPadStandardRes        = 4,    // iPad 1,2 Standard Resolution         (1024x768px)
    UIDevice_iPadHiRes              = 5     // iPad 3 High Resolution               (2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions) { }

+ (UIDeviceResolution) currentResolution;

@end
