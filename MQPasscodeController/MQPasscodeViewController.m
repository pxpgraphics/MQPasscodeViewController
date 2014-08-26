//
//  MQPasscodeViewController.m
//  MQPasscodeViewController
//
// Created by Paris Pinkney on 08/20/14.
//

/**
 Copyright (C) 2014 by Thomas Heß

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "MQPasscodeViewController.h"
#import "MQPasscodeView.h"
#import "MQBlurView.h"
#import "MQImageColors.h"
#import "UIImage+MQPasscodeAdditions.h"

@interface MQPasscodeViewController () <MQPasscodeViewDelegate>

@property (nonatomic, strong) MQPasscodeView *passcodeView;
@property (nonatomic, strong) MQBlurView *blurView;
@property (nonatomic, assign) NSArray *blurViewContraints;
@property (nonatomic, assign, getter = isBlurred) BOOL blurred;

@end

@implementation MQPasscodeViewController

#pragma mark - Lifecycle

- (instancetype)initWithDelegate:(id<MQPasscodeViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _backgroundColor = [UIColor clearColor];
        _translucentBackground = NO;
        _promptTitle = @"Enter Passcode";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
    
    self.passcodeView = [[MQPasscodeView alloc] initWithDelegate:self];
    self.passcodeView.backgroundColor = self.view.backgroundColor;
    self.passcodeView.promptTitle = self.promptTitle;
    self.passcodeView.promptColor = self.promptColor;
    self.passcodeView.hideLetters = self.hideLetters;
    self.passcodeView.disableCancel = self.disableCancel;
    self.passcodeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.passcodeView];
    // Center pin view.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passcodeView attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    CGFloat passcodeViewYOffset = 0.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        passcodeViewYOffset = -9.0f;
    } else {
        BOOL isFourInchScreen = (fabs(CGRectGetHeight([[UIScreen mainScreen] bounds]) - 568.0f) < DBL_EPSILON);
        if (isFourInchScreen) {
            passcodeViewYOffset = 25.5f;
        } else {
            passcodeViewYOffset = 18.5f;
        }
    }
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passcodeView attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:passcodeViewYOffset]];
}

#pragma mark - Custom accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if ([self.backgroundColor isEqual:backgroundColor]) {
        return;
    }

    _backgroundColor = backgroundColor;

    if (!self.translucentBackground) {
        self.view.backgroundColor = _backgroundColor;
        self.passcodeView.backgroundColor = _backgroundColor;
    }
}

- (void)setTranslucentBackground:(BOOL)translucentBackground
{
    if (_translucentBackground == translucentBackground) {
        return;
    }

    _translucentBackground = translucentBackground;

    if (_translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        self.passcodeView.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
        self.passcodeView.backgroundColor = self.backgroundColor;
        [self removeBlurView];
    }
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    if ([_promptTitle isEqualToString:promptTitle]) {
        return;
    }

    _promptTitle = [promptTitle copy];

    self.passcodeView.promptTitle = _promptTitle;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    if ([_promptColor isEqual:promptColor]) {
        return;
    }

    _promptColor = promptColor;

	self.view.tintColor = _promptColor;
    self.passcodeView.promptColor = _promptColor;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    if (_hideLetters == hideLetters) {
        return;
    }

    _hideLetters = hideLetters;

    self.passcodeView.hideLetters = _hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel
{
    if (_disableCancel == disableCancel) {
        return;
    }

    _disableCancel = disableCancel;

    self.passcodeView.disableCancel = _disableCancel;
}

#pragma mark - MQPasscodeViewDelegate

- (NSUInteger)passcodeLengthForpasscodeView:(MQPasscodeView *)passcodeView
{
    NSUInteger passcodeLength = [self.delegate passcodeLengthForpasscodeViewController:self];
    NSAssert(passcodeLength > 0, @"PIN length must be greater than 0");
    return MAX(passcodeLength, (NSUInteger)1);
}

- (BOOL)passcodeView:(MQPasscodeView *)passcodeView isPinValid:(NSString *)pin
{
    return [self.delegate passcodeViewController:self isPinValid:pin];
}

- (void)cancelButtonTappedInpasscodeView:(MQPasscodeView *)passcodeView
{
    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerWillDismissAfterPinEntryWasCancelled:)]) {
        [self.delegate passcodeViewControllerWillDismissAfterPinEntryWasCancelled:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissAfterPinEntryWasCancelled:)]) {
            [self.delegate passcodeViewControllerDidDismissAfterPinEntryWasCancelled:self];
        }
    }];
}

- (void)correctPinWasEnteredInpasscodeView:(MQPasscodeView *)passcodeView
{
    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerWillDismissAfterPinEntryWasSuccessful:)]) {
        [self.delegate passcodeViewControllerWillDismissAfterPinEntryWasSuccessful:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissAfterPinEntryWasSuccessful:)]) {
            [self.delegate passcodeViewControllerDidDismissAfterPinEntryWasSuccessful:self];
        }
    }];
}

- (void)incorrectPinWasEnteredInpasscodeView:(MQPasscodeView *)passcodeView
{
    if ([self.delegate userCanRetryInpasscodeViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(incorrectPinEnteredInpasscodeViewController:)]) {
            [self.delegate incorrectPinEnteredInpasscodeViewController:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerWillDismissAfterPinEntryWasUnsuccessful:)]) {
            [self.delegate passcodeViewControllerWillDismissAfterPinEntryWasUnsuccessful:self];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidDismissAfterPinEntryWasUnsuccessful:)]) {
                [self.delegate passcodeViewControllerDidDismissAfterPinEntryWasUnsuccessful:self];
            }
        }];
    }
}

#pragma mark - Private methods

- (void)addBlurView
{
	self.blurView = [[MQBlurView alloc] initWithImage:[self blurredContentImage]];
	CGFloat max = MAX(self.blurView.frame.size.width, self.blurView.frame.size.height);
	self.blurView.frame = CGRectMake(0.0, 0.0, max, max);
	if (!self.blurView.image) {
		self.blurView.image = [self blurredContentImage];
	}
    [self.view insertSubview:self.blurView belowSubview:self.passcodeView];

	/* 
	// FIXME: Uses way too much memory!
	MQImageColors *imageColors = [[MQImageColors alloc] initWithImage:[self contentImage] count:7];
	NSLog(@"Color: %@", imageColors.colors);
	self.promptColor = imageColors.colors[4];
	 */
}

- (UIImage *)blurredContentImage
{
	static UIImage *image = nil;

	if (!self.isBlurred) {
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			//Background Thread
			UIImage *blurredImage = [[self contentImage] applyLightEffect];
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				image = blurredImage;
				if (self.isBlurred) {
					[UIView animateWithDuration:0.5f animations:^{
						self.blurView.alpha = 1.0f;
					}];
				}
				//Run UI Updates
			});
		});
	}

	return image;

//	UIImage *image = [self contentImage];
//	if (!image) {
//		return nil;
//	}
//
//	return [image applyBlurWithRadius:20.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.75f]
//				saturationDeltaFactor:1.8f maskImage:nil];
}

- (UIImage *)contentImage
{
	static UIImage *blurredImage = nil;
	if (!self.isBlurred) {
		UIView *contentView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:MQPasscodeViewControllerContentViewTag];
		if (!contentView) {
			return nil;
		}

		CGSize size = self.view.bounds.size;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			UIGraphicsBeginImageContextWithOptions(size, NO, 0.1);
		} else {
			UIGraphicsBeginImageContextWithOptions(size, NO, 0);
		}
		[contentView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		blurredImage = image;
		self.blurred = YES;
		return image;
	} else {
		self.blurred = YES;
		return blurredImage;
	}
}

- (void)removeBlurView
{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
	self.blurred = NO;
}

@end
