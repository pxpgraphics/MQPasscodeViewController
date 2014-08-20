//
//  UIWindow+MQAdditions.m
//  MQPasscodeController
//
//  Created by Paris Pinkney on 8/4/14.
//  Copyright (c) 2014 Marqeta. All rights reserved.
//

#import "UIWindow+MQPasscodeAdditions.h"

@implementation UIWindow (MQPasscodeAdditions)

#pragma mark - Private methods

- (UIViewController *)currentViewController
{
	UIViewController *viewController = self.rootViewController;
	while (viewController.presentedViewController) {
		viewController = viewController.presentedViewController;
	}
	return viewController;
}

#pragma mark - Public methods

- (UIImage *)snapshotFromWindow
{
	// Adjust window size from device orientation.
	CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
	statusBarSize = CGSizeMake(MAX(statusBarSize.width, statusBarSize.height),
							   MIN(statusBarSize.height, statusBarSize.width));

	CGSize windowSize = self.frame.size;
	windowSize = CGSizeMake(MAX(windowSize.width, windowSize.height),
							MIN(windowSize.height, windowSize.width));

	CGSize size = CGSizeMake(windowSize.width, windowSize.height - statusBarSize.height);

	// Begin context with device scale.
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.center.x, self.center.y);
    CGContextConcatCTM(context, self.transform);
    CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);

	// Apply window tranforms to the absolute origin of the receiver.
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
			CGContextRotateCTM(context, (CGFloat)M_PI_2);
			CGContextTranslateCTM(context, 0, -size.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
			CGContextRotateCTM(context, (CGFloat)-M_PI_2);
			CGContextTranslateCTM(context, -size.height, 0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
			CGContextRotateCTM(context, (CGFloat)M_PI);
			CGContextTranslateCTM(context, -size.width, -size.height);
            break;
        default:
            break;
    }

	// Draw the window.
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }

	// Save the image.
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIViewController *)viewControllerForStatusBarHidden
{
	UIViewController *currentViewController = [self currentViewController];
	while ([currentViewController childViewControllerForStatusBarHidden]) {
		currentViewController = [currentViewController childViewControllerForStatusBarHidden];
	}
	return currentViewController;
}

- (UIViewController *)viewControllerForStatusBarStyle
{
	UIViewController *currentViewController = [self currentViewController];
	while ([currentViewController childViewControllerForStatusBarStyle]) {
		currentViewController = [currentViewController childViewControllerForStatusBarStyle];
	}
	return currentViewController;
}

@end
