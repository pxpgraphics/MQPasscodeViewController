//
//  UIWindow+MQAdditions.h
//  MQPegasus
//
//  Created by Paris Pinkney on 8/4/14.
//  Copyright (c) 2014 Marqeta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MQAdditions)

- (UIImage *)snapshotFromWindow;
- (UIViewController *)viewControllerForStatusBarHidden;
- (UIViewController *)viewControllerForStatusBarStyle;

@end
