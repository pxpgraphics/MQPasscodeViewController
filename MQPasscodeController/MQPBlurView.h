//
//  MQPBlurView.h
//  MQPegasus
//
//  Created by Paris Pinkney on 7/30/14.
//  Copyright (c) 2014 Marqeta. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Blur implementation, which displays a blurred image screenshot of the window cropped to its absolute bounds.
 * Hides its superview on '-redraw', temporarily.
 * Can remove or patch with UIVisualEffectView for iOS 8+ targets.
 */

@interface MQPBlurView : UIImageView <UIAppearanceContainer>

/**
 * Appearance:
 * All of the following properties should be set before showing the alert view.
 * See `+initialize` to learn the default values of all properties.
 */

// See `UIImage+MQAdditions.h/.m to learn how these three properties are used:
@property (nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat blurSaturationDeltaFactor UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *blurTintColor UI_APPEARANCE_SELECTOR;

// Text attributes
@property (nonatomic, copy) NSDictionary *buttonTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSDictionary *cancelButtonTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSDictionary *destructiveButtonTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;

// Duration of the show/dismiss animations. Defaults to 0.3.
@property (nonatomic) NSTimeInterval animationDuration UI_APPEARANCE_SELECTOR;

// Window visible before the blur view was presented.
@property (nonatomic, weak, readonly) UIWindow *previousKeyWindow;

// Window visible while the blur view is displayed.
@property (nonatomic, weak, readonly) UIWindow *keyWindow;

- (void)blurSnapshot;

@end