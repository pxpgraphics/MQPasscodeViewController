//
//  MQPBlurView.m
//  MQPegasus
//
//  Created by Paris Pinkney on 7/30/14.
//  Copyright (c) 2014 Marqeta. All rights reserved.
//

#import "MQPBlurView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+MQAdditions.h"
#import "UIWindow+MQAdditions.h"

static const NSTimeInterval kDefaultAnimationDuration = 0.3f;

@interface MQPBlurView ()

@property (nonatomic, assign, getter = shouldRedrawOnFrameChange) BOOL redrawOnFrameChange;
@property (nonatomic, weak, readwrite) UIWindow *previousKeyWindow;
@property (nonatomic, weak, readwrite) UIWindow *keyWindow;

@end

@implementation MQPBlurView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.clipsToBounds = YES;

		CGRect screenBounds = [UIScreen mainScreen].bounds;
		if (CGRectEqualToRect(self.frame, screenBounds)) {
			// Adjust frame for status bar and device orientation.
			CGPoint origin = screenBounds.origin;
			origin = CGPointMake(MIN(origin.x, origin.y),
								 MAX(origin.y, origin.x));

			CGSize size = CGSizeMake(MAX(screenBounds.size.width, screenBounds.size.height),
									 MIN(screenBounds.size.height, screenBounds.size.width));

			self.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
		}

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];

		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
		self.image = [self.previousKeyWindow snapshotFromWindow];
	}
	return self;
}

+ (void)initialize
{
	if (self != [MQPBlurView class]) {
		return;
	}

	MQPBlurView *appearance = [self appearance];
	[appearance setAnimationDuration:kDefaultAnimationDuration];
	[appearance setBlurRadius:16.0f];
	[appearance setBlurSaturationDeltaFactor:1.0f];
	[appearance setBlurTintColor:nil];

	/*
	 [appearance setBlurRadius:16.0f];
	 [appearance setBlurTintColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
	 [appearance setBlurSaturationDeltaFactor:1.8f];
	 [appearance setButtonHeight:60.0f];
	 [appearance setCancelButtonHeight:44.0f];
	 [appearance setAutomaticallyTintButtonImages:@YES];
	 [appearance setSelectedBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.2f]];
	 [appearance setCancelButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
	 NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
	 [appearance setButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f]}];
	 [appearance setDestructiveButtonTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
	 NSForegroundColorAttributeName : [UIColor redColor] }];
	 [appearance setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0f],
	 NSForegroundColorAttributeName : [UIColor grayColor] }];
	 [appearance setAnimationDuration:kDefaultAnimationDuration];
	 */
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIView

- (void)layoutSubviews
{
	[super layoutSubviews];

	if ([self shouldRedrawOnFrameChange]) {
		self.redrawOnFrameChange = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self blurSnapshot];
		});
	}
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];

	if (self.window) {
		self.keyWindow = self.window;
		[self blurSnapshot];
	}
}

#pragma mark - Private methods

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
//	self.redrawOnFrameChange = YES;
//
//	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
//
//	CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
//	CGAffineTransform rotation;
//
//	switch (interfaceOrientation) {
//        case UIInterfaceOrientationLandscapeLeft:
//            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
//            break;
//        case UIInterfaceOrientationLandscapeRight:
//            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
//            break;
//        case UIInterfaceOrientationPortraitUpsideDown:
//            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
//            break;
//        default:
//            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
//            break;
//    }
//
//	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
//		self.transform = rotation;
//	} completion:^(BOOL finished) {
//		// Fix invalidations when view is rotated too many times.
//		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//			UIInterfaceOrientation endInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//			if (interfaceOrientation != endInterfaceOrientation) {
//				// TODO: User moved phone again before animation ended: rotation animation can introduce errors here
//			}
//		});
//	}];
}

#pragma mark - Public methods

- (void)blurSnapshot
{
	BOOL wasHidden = self.superview.hidden;
	self.superview.hidden = YES;

	// Must invoke this on the main thread.
	UIImage *image = [self.image applyBlurWithRadius:self.blurRadius
										   tintColor:self.blurTintColor
							   saturationDeltaFactor:self.blurSaturationDeltaFactor
										   maskImage:nil];

	self.image = image;
	self.superview.hidden = wasHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
