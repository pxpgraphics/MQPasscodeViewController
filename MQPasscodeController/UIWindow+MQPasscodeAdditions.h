//
//  UIWindow+MQAdditions.h
//  MQPasscodeController
//
//  Created by Paris Pinkney on 8/4/14.
//  Copyright (c) 2014 Marqeta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MQPasscodeAdditions)

- (UIImage *)snapshotFromWindow;
- (UIViewController *)viewControllerForStatusBarHidden;
- (UIViewController *)viewControllerForStatusBarStyle;

@end
