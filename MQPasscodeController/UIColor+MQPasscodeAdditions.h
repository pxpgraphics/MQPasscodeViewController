//
//  UIColor+MQPasscodeAdditions.h
//  MQPasscodeController
//
//  Created by Paris Pinkney on 8/20/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MQPasscodeAdditions)

- (BOOL)isBlackOrWhite;
- (BOOL)isContrastingColor:(UIColor *)color;
- (BOOL)isDarkColor;
- (BOOL)isDistinct:(UIColor *)color;
- (CGFloat)luminance;
- (UIColor *)colorWithMinimumSaturation:(CGFloat)saturation;

+ (CAGradientLayer *)randomGradient;
+ (UIColor *)randomColor;

@end
